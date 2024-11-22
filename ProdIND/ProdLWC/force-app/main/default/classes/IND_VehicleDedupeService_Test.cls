/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_VehicleDedupeRequest IND_VehicleDedupeService IND_VehicleDedupeResponse class
History
Date            Author              Comments
-------------------------------------------------------------
29-12-2021      Satyam More       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_VehicleDedupeService_Test {
    @isTest
    public static void testVehicleDedupeService(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing',MobilePhone = '9701498575',Maker_Id__c='1002', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            String vehicleDedupeCallOutResponse;
            
            system.runAs(u){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vehicleDedupe = '{"customerCode":"CW1330664" ,"oldDealNo":"GRS00382T","vehicleRegisterationNumber":"GJ13AM1688","nocNo":"","product":"C","category":"N","subCategory":"UEB"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVehicleDedupeCallout(vehicleDedupe);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhIG8j6MGRqS52iayUGxXcrVOgcAzY9yY6nMMfG9ZQxfJmlWhraEaesxKPw77VnmLd+goVDesl9JX9to9+377mQ4VYtYcRh8lkEKY3v4MIzyuNokv0ve8sj92W7MT8SasIVrsXsm/aLqaL7L7Ym1F+0uane8P0xmzLitanKBWieM9rxYeCOw9OaBoCuwVe0PSlbNheffKcSIFcwbokRftryIA6bnetbp+tfX2e+QS90I9qmLE+bstFBYF6ySpJ/USA="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            
            
            
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                vehicleDedupeCallOutResponse= (String)IntegrationEngine.processVehicleDedupeCallOutResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Fetched Vehicle Dedupe details.","content":[{"Proceed_Flag":"N","NOC_Number_as_per_DB":"","Description":"Invalid option selected. Please recheck - Product Segment Mismatch"}]}}';
            System.assertEquals(responseActual,vehicleDedupeCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void testVehicleDedupeService2(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vehicleDedupe = '{"customerCode":"" ,"oldDealNo":"GRS00382T","vehicleRegisterationNumber":"GJ13AM1688","nocNo":"","product":"C","category":"N","subCategory":"UEB"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVehicleDedupeCallout(vehicleDedupe);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhIG8j6MGRqS52iayUGxXcrVOgcAzY9yY6nMMfG9ZQxfJmlWhraEaesxKPw77VnmLd+goVDesl9JX9to9+377mQ4VYtYcRh8lkEKY3v4MIzyuNokv0ve8sj92W7MT8SasIVrsXsm/aLqaL7L7Ym1F+0uane8P0xmzLitanKBWieM9rxYeCOw9OaBoCuwVe0PSlbNheffKcSIFcwbokRftryIA6bnetbp+tfX2e+QS90I9qmLE+bstFBYF6ySpJ/USA="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vehicleDedupeCallOutResponse= (String)IntegrationEngine.processVehicleDedupeCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Fetched Vehicle Dedupe details.","content":[{"Proceed_Flag":"N","NOC_Number_as_per_DB":"","Description":"Invalid option selected. Please recheck - Product Segment Mismatch"}]}}';
            System.assertEquals(responseActual,vehicleDedupeCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.CustomerCode, 'Exception');
        }
    }
    
    @isTest
    public static void testVehicleDedupeService3(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vehicleDedupe = '{"customerCode":"CW1330664" ,"oldDealNo":"","vehicleRegisterationNumber":"GJ13AM1688","nocNo":"","product":"C","category":"N","subCategory":"UEB"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVehicleDedupeCallout(vehicleDedupe);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhIG8j6MGRqS52iayUGxXcrVOgcAzY9yY6nMMfG9ZQxfJmlWhraEaesxKPw77VnmLd+goVDesl9JX9to9+377mQ4VYtYcRh8lkEKY3v4MIzyuNokv0ve8sj92W7MT8SasIVrsXsm/aLqaL7L7Ym1F+0uane8P0xmzLitanKBWieM9rxYeCOw9OaBoCuwVe0PSlbNheffKcSIFcwbokRftryIA6bnetbp+tfX2e+QS90I9qmLE+bstFBYF6ySpJ/USA="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vehicleDedupeCallOutResponse= (String)IntegrationEngine.processVehicleDedupeCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Fetched Vehicle Dedupe details.","content":[{"Proceed_Flag":"N","NOC_Number_as_per_DB":"","Description":"Invalid option selected. Please recheck - Product Segment Mismatch"}]}}';
            System.assertEquals(responseActual,vehicleDedupeCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.OldDealNo, 'Exception');
        }
    }
    
    @isTest
    public static void testVehicleDedupeService4(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vehicleDedupe = '{"customerCode":"CW1330664" ,"oldDealNo":"GRS00382T","vehicleRegisterationNumber":"","nocNo":"","product":"C","category":"N","subCategory":"UEB"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVehicleDedupeCallout(vehicleDedupe);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhIG8j6MGRqS52iayUGxXcrVOgcAzY9yY6nMMfG9ZQxfJmlWhraEaesxKPw77VnmLd+goVDesl9JX9to9+377mQ4VYtYcRh8lkEKY3v4MIzyuNokv0ve8sj92W7MT8SasIVrsXsm/aLqaL7L7Ym1F+0uane8P0xmzLitanKBWieM9rxYeCOw9OaBoCuwVe0PSlbNheffKcSIFcwbokRftryIA6bnetbp+tfX2e+QS90I9qmLE+bstFBYF6ySpJ/USA="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vehicleDedupeCallOutResponse= (String)IntegrationEngine.processVehicleDedupeCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Fetched Vehicle Dedupe details.","content":[{"Proceed_Flag":"N","NOC_Number_as_per_DB":"","Description":"Invalid option selected. Please recheck - Product Segment Mismatch"}]}}';
            System.assertEquals(responseActual,vehicleDedupeCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.VehicleRegistrationNumber, 'Exception');
        }
    }
    
    @isTest
    public static void testVehicleDedupeService5(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vehicleDedupe = '{"customerCode":"CW1330664" ,"oldDealNo":"GRS00382T","vehicleRegisterationNumber":"GJ13AM1688","nocNo":"","product":"","category":"N","subCategory":"UEB"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVehicleDedupeCallout(vehicleDedupe);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhIG8j6MGRqS52iayUGxXcrVOgcAzY9yY6nMMfG9ZQxfJmlWhraEaesxKPw77VnmLd+goVDesl9JX9to9+377mQ4VYtYcRh8lkEKY3v4MIzyuNokv0ve8sj92W7MT8SasIVrsXsm/aLqaL7L7Ym1F+0uane8P0xmzLitanKBWieM9rxYeCOw9OaBoCuwVe0PSlbNheffKcSIFcwbokRftryIA6bnetbp+tfX2e+QS90I9qmLE+bstFBYF6ySpJ/USA="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vehicleDedupeCallOutResponse= (String)IntegrationEngine.processVehicleDedupeCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Fetched Vehicle Dedupe details.","content":[{"Proceed_Flag":"N","NOC_Number_as_per_DB":"","Description":"Invalid option selected. Please recheck - Product Segment Mismatch"}]}}';
            System.assertEquals(responseActual,vehicleDedupeCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Product, 'Exception');
        }
    }
    
    @isTest
    public static void testVehicleDedupeService6(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vehicleDedupe = '{"customerCode":"CW1330664" ,"oldDealNo":"GRS00382T","vehicleRegisterationNumber":"GJ13AM1688","nocNo":"","product":"C","category":"","subCategory":"UEB"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVehicleDedupeCallout(vehicleDedupe);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhIG8j6MGRqS52iayUGxXcrVOgcAzY9yY6nMMfG9ZQxfJmlWhraEaesxKPw77VnmLd+goVDesl9JX9to9+377mQ4VYtYcRh8lkEKY3v4MIzyuNokv0ve8sj92W7MT8SasIVrsXsm/aLqaL7L7Ym1F+0uane8P0xmzLitanKBWieM9rxYeCOw9OaBoCuwVe0PSlbNheffKcSIFcwbokRftryIA6bnetbp+tfX2e+QS90I9qmLE+bstFBYF6ySpJ/USA="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vehicleDedupeCallOutResponse= (String)IntegrationEngine.processVehicleDedupeCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Fetched Vehicle Dedupe details.","content":[{"Proceed_Flag":"N","NOC_Number_as_per_DB":"","Description":"Invalid option selected. Please recheck - Product Segment Mismatch"}]}}';
            System.assertEquals(responseActual,vehicleDedupeCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Category, 'Exception');
        }
    }
    
    @isTest
    public static void testVehicleDedupeService7(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vehicleDedupe = '{"customerCode":"CW1330664" ,"oldDealNo":"GRS00382T","vehicleRegisterationNumber":"GJ13AM1688","nocNo":"","product":"C","category":"N","subCategory":""}';
            
            Continuation con = (Continuation)IntegrationEngine.doVehicleDedupeCallout(vehicleDedupe);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhIG8j6MGRqS52iayUGxXcrVOgcAzY9yY6nMMfG9ZQxfJmlWhraEaesxKPw77VnmLd+goVDesl9JX9to9+377mQ4VYtYcRh8lkEKY3v4MIzyuNokv0ve8sj92W7MT8SasIVrsXsm/aLqaL7L7Ym1F+0uane8P0xmzLitanKBWieM9rxYeCOw9OaBoCuwVe0PSlbNheffKcSIFcwbokRftryIA6bnetbp+tfX2e+QS90I9qmLE+bstFBYF6ySpJ/USA="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vehicleDedupeCallOutResponse= (String)IntegrationEngine.processVehicleDedupeCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Fetched Vehicle Dedupe details.","content":[{"Proceed_Flag":"N","NOC_Number_as_per_DB":"","Description":"Invalid option selected. Please recheck - Product Segment Mismatch"}]}}';
            System.assertEquals(responseActual,vehicleDedupeCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.SubCategory, 'Exception');
        }
    }
    
    @isTest
    public static void testVehicleDedupeService8(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vehicleDedupe = '{"customerCode":"CW1330664" ,"oldDealNo":"GRS00382T","vehicleRegisterationNumber":"GJ13AM1688","nocNo":"","product":"C","category":"N","subCategory":"UEB"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVehicleDedupeCallout(vehicleDedupe);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhIG8j6MGRqS52iayUGxXcrVOgcAzY9yY6nMMfG9ZQxfJmlWhraEaesxKPw77VnmLd+goVDesl9JX9to9+377mQ4VYtYcRh8lkEKY3v4MIzyuNokv0ve8sj92W7MT8SasIVrsXsm/aLqaL7L7Ym1F+0uane8P0xmzLitanKBWieM9rxYeCOw9OaBoCuwVe0PSlbNheffKcSIFcwbokRftryIA6bnetbp+tfX2e+QS90I9qmLE+bstFBYF6ySpJ/USA="}');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vehicleDedupeCallOutResponse= (String)IntegrationEngine.processVehicleDedupeCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Fetched Vehicle Dedupe details.","content":[{"Proceed_Flag":"N","NOC_Number_as_per_DB":"","Description":"Invalid option selected. Please recheck - Product Segment Mismatch"}]}}';
            System.assertEquals(responseActual,vehicleDedupeCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'No Response Found.', 'Exception');
        }
    }
    
}