/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   Test class for IND_MembershipRequest class 
Apex Class:    IND_MembershipRequest,IntegrationEngine,IND_MembershipResponse,IND_MembershipService
History
Date            Author              Comments
-------------------------------------------------------------
12-17-2021      Manish Baldota       Created
------------------------------------------------------------*/
@isTest
public class IND_MembershipService_Test {
    // @Method:		createTestData
    // @Created by:	Manish Baldota
    // @Description:Test setup method to create the test data for IND_MembershipRequest_Test classs
    // @Param:		''	
    // @Return: 	'' 
    @TestSetup
    public static void createTestData(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opp.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
    }
    // @Method:		TestServiceMetthod
    // @Created by:	Manish Baldota
    // @Description:Test setup method to create the test data for IND_MembershipRequest_Test classs
    // @Param:		''	
    // @Return: 	'' 
    @isTest
    public static void testIND_MembershipService(){
        try{
            
              Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
           
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
					TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
            System.runAs(u){
                Opportunity optg1 = new Opportunity();
                optg1.StageName = 'Qualification';
                optg1.CloseDate = Date.newInstance(2021, 1, 11);
                optg1.Name = 'testone';
            	optg1.Lead_number__c = 'L18062200038';
                insert optg1;
                
                Applicant__c applicant = new Applicant__c();
                applicant.Opportunity__c = optg1.Id;
                applicant.Contact_number__c = '9743514830';
                applicant.Applicant_Type__c = 'Borrower';
                insert applicant;
            
            Continuation con = (Continuation)IntegrationEngine.doMembershipCallout(applicant.Id,'{"Application_No": "MCI8971254_894378439","maker_Id": "98427","MembershipType": "mci","Consent": "Y","MembershipId": "1","year_of_reg": "1960","medical_council": "Andhra Pradesh Medical Council"}',optg1.Id);
           
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"orbO8n5L4OqIo+JKCMD/u9JQ32t516JBvjeue80zMWzjOqtS64zaTo/5MwWmn6QPm54a6Ab9ba8gSspyarfU8lC1ShJKt8b1ZrZ0o3MDadNoLo+NrLIrZLGsP5b9tul+CuQva4zsMeeNu6Ct5WnpJNEHd+jtix1LNjLzVvIKJqMQvoJveKF4E0hR8l2/NoRQSUgtS4spdljt7nXebX4S7D0xS+8KpaY7ekHVYr/TleO3CsuPOASKETJSunkRgX3J"}');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState; 
            String membershipResponse='';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processMembershipAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected ='{"body":null,"ResponseData":null,"RequestId":null}';
            System.assertEquals(responseExpected, membershipResponse);
        } 
        }catch(Exception ex){
            system.debug('ex.getMessage()::'+ex.getMessage());
            System.assertEquals(ex.getMessage(),'Please enter Lead Id.');
        }
        
    }
    
    // @Method:		testIND_MembershipServiceNegative
    // @Created by:	Manish Baldota
    // @Description:Test setup method to create the test data for IND_MembershipRequest_Test classs
    // @Param:		''	
    // @Return: 	'' 
    @isTest
    public static void testIND_MembershipServiceNegative(){
        try{
                          Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
           
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
					TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
            System.runAs(u){
                Opportunity optg1 = new Opportunity();
                optg1.StageName = 'Qualification';
            	optg1.Lead_number__c = 'L18062200038';
                optg1.CloseDate = Date.newInstance(2021, 1, 11);
                optg1.Name = 'testone';
                insert optg1;
                
                Applicant__c applicant = new Applicant__c();
                applicant.Opportunity__c = optg1.Id;
                applicant.Contact_number__c = '9743514830';
                applicant.Applicant_Type__c = 'Borrower';
                insert applicant;          
            Continuation con = (Continuation)IntegrationEngine.doMembershipCallout(applicant.Id,'',optg1.Id);
           
            HttpResponse response = new HttpResponse();
            response.setBody('{JData":"62AJ1Cg+PQw/eIEdwr8qsCRiCnFaBuyaY0LQz/x7phbg9umrpO8jOcSaQ9AHcoCbP2g9iZ6+cRrva417Sx2kC3/TzKmOLkZrWBVI+IlqmwJebkkyMwa7857iaC+AqRRd7LUrfbEDhaMlzPM8NWpPTxSEaQmuR5LeKKXwyBJwW9jgS16Auyz295cGwEGjAf/yHS9ApKMeXES8YdqZvauylfRkp+GNmiWoLE9Vinf7WvFdg9fLXNef4rn5pW+hw6x3VarctoL67GUFRasRsQQ9rSDYfvB2StB4HXtDQtpJIg9jeh0Uy7x2Zv/O6YEiQLyY+NlrUDpVlr2N6smGBf39bIrYPQ+ZI4xBFQJimTHQe9KD/5FuAz2xI5HQl+J+8EBMntSEbPCtTJjS/lJw7fYHePM1+gC3zvVH34EBV+KtD4hfqxcLUzoqigl+cEBn5XZymmnkGdXCLkcpL2fg3cmBpnAt+jDhcHw7eEMPJfUyqQsMmM21f3Vvi1K6noFNbTgEpno9PpmSTmMe1xGrwnKAyOyxk3Ue2eb9g8aCWePIFcD1iOG+RpuXoKHbNXTGFV+a67VYfpmLMQFfRhOr0tPMIM3E4jps5Mg4nisAHCOubhEeZ3Or64ecogpQRZCBMl7In7p3vbXBNYnrcLyeSNsjhPYXPsmXhVka0SRqDpMsj5ZUXudUZmo49mQM10ILDY8FYMzu1lLe6YiKRtvbSR2UX4I9u0fysapk7CQQFK2e1jNq281fhpgsX27i6HeEClvuIfXzpbYcHAdjFA0nIQBFx+qtXFy4qwvHAs3rHowMjHN6pOdiB+fDq9u/CrrFGdnmGTXRXvoaJx+x3rFhVNne15TfB4CLAp5STrtmdblXAhGeCRfZyPabP1WVRConVeazT6//9oX9sgUBSzZeuIRrkN7VCxW3hV4/Zy/8bI/3nl7pMIoTt09nHZ5O0AsiNwN/KOydwDHNrT9u4xW6Uu1+GWgJkF58G7ymgAgZrOYzKpHl5s+rUQESPqKFNn2glLmShpdO2vR0Xt43hysM/gRAgYFhYUZqd8hQ6Gc15AQIDMYf5vkoREL2GRGzSEYbq33FSTcTiq3hlIZ0lb2CZ44Dy1FNBDm4Oaist36Yyk6UC+9YdNv8BARKY/HvM5suZdLWrD6OtsP7oRtflkUp/09xxaxOjAoq8JBDdnRDNRdHwMlcV/WNNWjhsJONpvUOk4IX25s/f66FUQm18BpiYNnfNE4v5zt3zGsGbUWN0QdTx03jIEFHU33Ow91xHZq+eWPu5dKKN2riaKWQu+EHgLi18IaEgFd6kQ6KO03S3TGcdRYYWGeWY+Cs4KeHfbRbuO0t39l2glQiqDz/cpwKCWV+Q76VBGcBtd07ft0v8xuNRWp4JND6O8wcwKSR+0na6v2hjxiQ5ufshVwmvpuNJ3jF9OCyCsYsmzdW8rkujl3EVCeXdJnY+Li+01GiNSZDlDGWK8NM5uGqA9kkfDxto1fEkMCgFwKSCyOo0QgUJ4J2kkwBM/KmQpJZndDd/K0VKqkXVj2mWYWMemaVeKVCVDl0aDxzxcYWa4JsLJKm1wd6sJ2x1gCtc5b+2JtiUq8fZKNNJyr194kocanX67rhoib2chNOXG1BVBqfga5LioN5hK8=}');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processMembershipAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, membershipResponse);
            } 
        }
        catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please provide valid membership Id or Membership type details.');
        }
        
    }
    
    // @Method:		TestServiceMetthod
    // @Created by:	Manish Baldota
    // @Description:Test setup method to create the test data for IND_MembershipRequest_Test classs
    // @Param:		''	
    // @Return: 	'' 
    @isTest
    public static void testIND_MembershipService2(){
        try{
            
              Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
           
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
					TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
            System.runAs(u){
                Opportunity optg1 = new Opportunity();
                optg1.StageName = 'Qualification';
                optg1.CloseDate = Date.newInstance(2021, 1, 11);
                optg1.Name = 'testone';
            	optg1.Lead_number__c = 'L18062200038';
                insert optg1;
                
                Applicant__c applicant = new Applicant__c();
                applicant.Opportunity__c = optg1.Id;
                applicant.Contact_number__c = '9743514830';
                applicant.Applicant_Type__c = 'Borrower';
                insert applicant;
            
            Continuation con = (Continuation)IntegrationEngine.doMembershipCallout(applicant.Id,'{"Application_No": "MCI8971254_894378439","maker_Id": "98427","MembershipType": "mci","Consent": "Y","MembershipId": "1","year_of_reg": "1960","medical_council": "Andhra Pradesh Medical Council"}',optg1.Id);
           
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"orbO8n5L4OqIo+JKCMD/u9JQ32t516JBvjeue80zMWzjOqtS64zaTo/5MwWmn6QPm54a6Ab9ba8gSspyarfU8lC1ShJKt8b1ZrZ0o3MDadNoLo+NrLIrZLGsP5b9tul+CuQva4zsMeeNu6Ct5WnpJNEHd+jtix1LNjLzVvIKJqMQvoJveKF4E0hR8l2/NoRQSUgtS4spdljt7nXebX4S7D0xS+8KpaY7ekHVYr/TleO3CsuPOASKETJSunkRgX3J"}');            
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState; 
            String membershipResponse='';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processMembershipAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected ='{"body":null,"ResponseData":null,"RequestId":null}';
            System.assertEquals(responseExpected, membershipResponse);
        } 
        }
            catch(Exception ex){
            system.debug('ex.getMessage()::'+ex.getMessage());
            System.assertEquals(ex.getMessage(),'No Response Found.');
        }
    }
    
}