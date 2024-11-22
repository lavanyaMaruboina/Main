/*------------------------------------------------------------
Author:        Nagendra pindipolu
Company:       Persistent Systems
Description:   Test class for IND_BREScorecardRequest class 
Apex Class:    IND_BREScorecardRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-30-2021      Nagendra pindipolu       Created
------------------------------------------------------------*/
@isTest
public class IND_BREscorecardService_Test {
   
    // @Method:		TestServiceMetthod
    // @Created by:	Nagendra pindipolu
    // @Description:Test setup method to create the test data for IND_BREscorecardRequest classs
    // @Param:		''	
    // @Return: 	''  
   
    
     @isTest
    public static void testBREscorecardService1(){
        try{
           Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser42@testorg.com.psdev1');
            insert u;
            system.runAs(u){
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            
            String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestDLDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Continuation con = (Continuation)IntegrationEngine.doBREscoreCardCallout(applicant.Id,opp.Id);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"q8q2HB/BfPvbqadkjV43lyaJmkoHWEyswtfMzVEEBzzRLWVdOjq0IlF9FAnpxA4L/iuEln7z82AVf05HvTy3aWRtggAQz+e2XfkHXiPC70rbsP3r4WDZd4JFx8C9/IcBNjDUMpsXjUQIaiNGKaukGtVy7NFg5BlLfrgBVwQUv4KoC6pOrQz6N1fujXUujYKqy/OWJ9QLPh0PclfZvqSwrphgJFi+13bT6HB7R6YzcLK4Ay1r/gMn6P+jC4nhwmfmBmAKaQzbqBOwJlm2Re2pxtEtNQvO9VNV0vsPGl7Ejs0="}');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState; 
            String membershipResponse = '';
       //     
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processBREscoreCardAPIResponse(labels, continuationState);
            Test.stopTest();
        //       
            String responseExpected ='{"body":null,"Color_Code":"#ffff00","BRE_Decision_Desc":"The customers vehicle loan application is Under Review. Please proceed to collect all required details to help create the best offer","BRE_Decision":"Yellow"}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Date Of Birth is required.');
        }
    }
    
    @isTest
    public static void testBREscorecardService12(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser422@testorg.com.psdev1');
            insert u;
           
            system.runAs(u){
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            applicant.Applicant_Type__c ='Borrower';
            String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
                
            Id recordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
                
            Documents__c document = TestDataUtility.createTestDLDocs(false,applicant,opp);
            document.RecordTypeId = recordTypeId;
            document.Proof_of_Identity_POI__c = true;
            document.Is_Active__c = true;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Continuation con = (Continuation)IntegrationEngine.doBREscoreCardCallout(applicant.Id,opp.Id);
            
        	}
        } catch(Exception ex){
            System.debug('Exception >>> '+ex.getMessage()+'  lineNumber >>> '+ex.getLineNumber());
            System.assertEquals(ex.getMessage(),'Pincode is Missing');
        }
    }
       @isTest
    public static void validateException(){
        try{
            IND_BREscoreCardService.getBREscoreCardRequest(null, null,null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }   
    }
}