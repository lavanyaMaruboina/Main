@isTest
public class DSA_BREscorecardService_Test {

    // @Method:		TestServiceMetthod
    // @Created by:	Nagendra pindipolu
    // @Description:Test setup method to create the test data for IND_BREscorecardRequest classs
    // @Param:		''
    // @Return: 	'' 
    @isTest
    public static void testBREscorecardService1(){
        try {
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',User_Id__c = '29927_MO',
                        TimeZoneSidKey='America/Los_Angeles',
                        UserName='standarduser4@testorg.com.psdev1');
            insert u;
            System.runAs(u) {
                //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
                Opportunity opp = TestDataUtility.createTestOpportunity(false);
                if (Schema.sObjectType.Opportunity.isCreateable()){
                    insert opp;
                }

                Applicant__c applicant = TestDataUtility.createTestApplicantForLTV(false);
                applicant.Opportunity__c=opp.Id;
                String loanAppId = applicant.Opportunity__r.id;
                if (Schema.sObjectType.Applicant__c.isCreateable()){
                    insert applicant;
                }

                Documents__c document = TestDataUtility.createTestKYCDocForBre(false,applicant,opp);
                // if (Schema.sObjectType.Documents__c.isCreateable()){
                    insert document;
                // }

                Continuation con = (Continuation)DSA_IntegrationEngine.doBREscorecardCallout(applicant.Id,opp.Id);

                //Map<String, HttpRequest> requests = con.getRequests();
                //system.assert(requests.size() == 1);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('{"JData":"q8q2HB/BfPvbqadkjV43lyaJmkoHWEyswtfMzVEEBzzRLWVdOjq0IlF9FAnpxA4L/iuEln7z82AVf05HvTy3aWRtggAQz+e2XfkHXiPC70rbsP3r4WDZd4JFx8C9/IcBNjDUMpsXjUQIaiNGKaukGtVy7NFg5BlLfrgBVwQUv4KoC6pOrQz6N1fujXUujYKqy/OWJ9QLPh0PclfZvqSwrphgJFi+13bT6HB7R6YzcLK4Ay1r/gMn6P+jC4nhwmfmBmAKaQzbqBOwJlm2Re2pxtEtNQvO9VNV0vsPGl7Ejs0="}');
                response.setStatusCode(200);

                String continuationLabel = DSA_IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                Object continuationState= DSA_IntegrationEngine.continuationState;
                String membershipResponse = '';
            //     system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                membershipResponse = (String)DSA_IntegrationEngine.processBREscorecardAPIResponse(labels, DSA_IntegrationEngine.continuationState);
                Test.stopTest();
            //        }
                String responseExpected ='{"body":null,"application":null}';
                System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Pincode is Missing');
        }
    }
        @isTest
    public static void validateException(){
        try{
            IND_BREscoreCardServiceDSA.getBREscoreCardRequest(null, null,null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
    }
}