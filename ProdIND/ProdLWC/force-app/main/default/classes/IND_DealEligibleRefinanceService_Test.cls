/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   Test class created to validate the IND_DealEligibleRefinanceRequest, IND_DealEligibleRefinanceService and IND_DealEligibleRefinanceResponse class
History
Date            Author              Comments
-------------------------------------------------------------
22-12-2021      Divya Jawale      Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_DealEligibleRefinanceService_Test {
    @isTest
    public static void testDealEligibleRefinanceService(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(true);
            Continuation con = (Continuation)IntegrationEngine.doDealEligibleRefinanceCallout(opp.Id,'123');
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpEwn9g3DFyqe/zXu96mLCsvYS4YFv6mr7vRY7Ns7WcW/O2Q0ibhNA8kjuWzN0JJjdwR5yGEbshn+rjDdiLl51lQb21YaKVA3xvETNawWhAIn9bILI8VIoXT6KmcMnSTcgGtDgd8E04rsjh27A2sjKlG+cJAenOWfwzyZkoCOyuowBDtoyFbr7xdSSWgTh+nbx"}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String dealEligibleCallOutResponse= (String)IntegrationEngine.processDealEligibleRefinanceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Deal Eligible Refinance","content":[{"RefinanceEligible":"No ","Product":"H","EligibilityAmount":"0.0000","DealNumber":"TTU12519H"}]}}';
        //    System.assertEquals(responseActual,dealEligibleCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception','Exception');
        }
    }
    
    @isTest
    public static void testDealEligibleRefinanceService2(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunityforCarwalePricesAPI(true);
            Continuation con = (Continuation)IntegrationEngine.doDealEligibleRefinanceCallout(opp.Id,'123');
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpEwn9g3DFyqe/zXu96mLCsvYS4YFv6mr7vRY7Ns7WcW/O2Q0ibhNA8kjuWzN0JJjdwR5yGEbshn+rjDdiLl51lQb21YaKVA3xvETNawWhAIn9bILI8VIoXT6KmcMnSTcgGtDgd8E04rsjh27A2sjKlG+cJAenOWfwzyZkoCOyuowBDtoyFbr7xdSSWgTh+nbx"}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String dealEligibleCallOutResponse= (String)IntegrationEngine.processDealEligibleRefinanceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Deal Eligible Refinance","content":[{"DealNumber":"TTU12519H","Product":"H","RefinanceEligible":"No ","EligibilityAmount":"0.0000"}]}}';
            System.assertEquals(responseActual,dealEligibleCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.LeadId,'Exception');
        }
    }
    
    @isTest
    public static void testDealEligibleRefinanceService3(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunityForEligibleMaster(true);
            Continuation con = (Continuation)IntegrationEngine.doDealEligibleRefinanceCallout(opp.Id,'123');
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpEwn9g3DFyqe/zXu96mLCsvYS4YFv6mr7vRY7Ns7WcW/O2Q0ibhNA8kjuWzN0JJjdwR5yGEbshn+rjDdiLl51lQb21YaKVA3xvETNawWhAIn9bILI8VIoXT6KmcMnSTcgGtDgd8E04rsjh27A2sjKlG+cJAenOWfwzyZkoCOyuowBDtoyFbr7xdSSWgTh+nbx"}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String dealEligibleCallOutResponse= (String)IntegrationEngine.processDealEligibleRefinanceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Deal Eligible Refinance","content":[{"DealNumber":"TTU12519H","Product":"H","RefinanceEligible":"No ","EligibilityAmount":"0.0000"}]}}';
           // System.assertEquals(responseActual,dealEligibleCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.deal_Number,'Exception');
        }
    }
    @isTest
    public static void testDealEligibleRefinanceService4(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunityForDealEligible(true);
            
            Continuation con = (Continuation)IntegrationEngine.doDealEligibleRefinanceCallout(opp.Id,'123');
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpEwn9g3DFyqe/zXu96mLCsvYS4YFv6mr7vRY7Ns7WcW/O2Q0ibhNA8kjuWzN0JJjdwR5yGEbshn+rjDdiLl51lQb21YaKVA3xvETNawWhAIn9bILI8VIoXT6KmcMnSTcgGtDgd8E04rsjh27A2sjKlG+cJAenOWfwzyZkoCOyuowBDtoyFbr7xdSSWgTh+nbx"}';
            response.setBody(body);      
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String dealEligibleCallOutResponse= (String)IntegrationEngine.processDealEligibleRefinanceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Deal Eligible Refinance","content":[{"DealNumber":"TTU12519H","Product":"H","RefinanceEligible":"No ","EligibilityAmount":"0.0000"}]}}';
            System.assertEquals(responseActual,dealEligibleCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Product,'Exception');
        }
    }
    
    @isTest
    public static void testDealEligibleRefinanceService5(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(true);
            Continuation con = (Continuation)IntegrationEngine.doDealEligibleRefinanceCallout(opp.Id,'123');
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpEwn9g3DFyqe/zXu96mLCsvYS4YFv6mr7vRY7Ns7WcW/O2Q0ibhNA8kjuWzN0JJjdwR5yGEbshn+rjDdiLl51lQb21YaKVA3xvETNawWhAIn9bILI8VIoXT6KmcMnSTcgGtDgd8E04rsjh27A2sjKlG+cJAenOWfwzyZkoCOyuowBDtoyFbr7xdSSWgTh+nbx"}';
            response.setBody(body);
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String dealEligibleCallOutResponse= (String)IntegrationEngine.processDealEligibleRefinanceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Deal Eligible Refinance","content":[{"RefinanceEligible":"No ","Product":"H","EligibilityAmount":"0.0000","DealNumber":"TTU12519H"}]}}';
        //    System.assertEquals(responseActual,dealEligibleCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Something went wrong. Please retry.','Exception');
        }
    }
}