/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   Test class created to validate the IND_InsuranceRecommendationRequest IND_InsuranceRecommendationService IND_InsuranceRecommendationResponse class
History
Date            Author              Comments
-------------------------------------------------------------
18-01-2022      Divya Jawale       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_InsuranceRecommendationService_Test {
@isTest
    public static void testInsuranceRecommendationService(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"'+applicant.Gender__c+'","Product":"'+opp.Product_Type__c+'","Vehicle_Category":"'+opp.Vehicle_Type__c+'","Fin_Amount":"300000","Balance_Available":"140000","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Gender is required.');
        }
    }
    
    @isTest
    public static void testInsuranceRecommendationService2(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"53453" ,"vehicleId":"","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"'+applicant.Gender__c+'","Product":"'+opp.Product_Type__c+'","Vehicle_Category":"U","Fin_Amount":"300000","Balance_Available":"140000","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.VehicleId, 'Exception');
        }
    }
    @isTest
    public static void testInsuranceRecommendationService3(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"'+applicant.Gender__c+'","Product":"'+opp.Product_Type__c+'","Vehicle_Category":"U","Fin_Amount":"300000","Balance_Available":"140000","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.ApplicationNo, 'Exception');
        }
    }
    
    @isTest
    public static void testInsuranceRecommendationService4(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"5432123" ,"vehicleId":"1","Variant":"","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"'+applicant.Gender__c+'","Product":"ALTONVXI6","Vehicle_Category":"U","Fin_Amount":"300000","Balance_Available":"140000","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Product, 'Exception');
        }
    }
    @isTest
    public static void testInsuranceRecommendationServiceAge(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"","gender":"'+applicant.Gender__c+'","Product":"Car","Vehicle_Category":"'+opp.Vehicle_Type__c+'","Fin_Amount":"300000","Balance_Available":"140000","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"g0B3b1vDdO/jNH/nOcUjwG2SJUhIK8Rk5BieffBDZpv0or4ZVTccoJgiUeIYwUCzwWcHZgCj0blxPkLkelg1aU95vNmDFChuWWksc1XxSv6puJD0Whlf6REeBwDoruA+F1KPIjoMxBEhMO1kCisFuMd/ro/YCAjJZxckwX+vngpN55CulFcyjDG96Z2pLh7t48qPD/XoB6DnMOAdOvA6e2HnxYCE+t+edArSHyQw2Y0c1M2w+e736rcVHFylrh4O+yWHKxyT1/TqdrOnp3qeRqbhtgbMmYhogsLFCUy+oEg7hJvF8OnJfVXPBid8S9vHiieQvvnjzRkhuh54h4KsiYiVJiGPLqEESrDApgk5Cee0Qu4u59LPmiGvVEe0K0oEnEU42awW177PkTC/WPExYPu3AjauNIfE6KBd1T0B87+prMY/UOYDtWFFhq3qPAEMKB5shc3T/+zp90bJE45Py4LXuH3yRBx1ctoDp4/VKmiZ2emfPrRFagUOBuCJWHC+v5gzVnS4RjWb9F7Wcdli0ajiM0AERoI/r6oTGNqru7ZmAYvm4IUz7ZsbD5d3jX76ekO61+2UvAF2/42+jtolI315ia88RDSGXNlAdoHOIFe1IP6WGDN6FnWq25+E/wuHSRRaB+PgnUJRxqiKqHFE4eip+s+5CP3O0k915aYB2l93DuOC28qZYFKrqQzOlgqSyfe6vII4/EUXVPY+FOW7+5CqHo4OJ4hAQc+BYBMEoEqpz8BOK0kE+ZR7e2kQhJPv/bQYqxBmeXISVbT092Br/woTF3evgPOn5l/9MuayfeWgY1AptJB0DJWFyq5sbTI33by52R+ECRDFpBa8dNE6Zy5kAIIF/Uc7LeP8o9+6DQZGvcLg5YT9br7syFbMnw5/k5B6MB2DWoqaNsXRQMcRrSDhsuk3umqqf3FQubn8oqdIR+L4iKjqdn+2sN6UeBaQQDe2yb/nna9v/IBkFKoDcLqTLqtJAa4/nDQhQMmbdrrjlO1lMipzK3WQct3Vys4D7El/6nVH1wGHrpdOZA7OB9WGRxdSXYAMiX0vXrwV1kGMoGVOBLIzqnkTI2xPe6aCbLoBZ2pA28zfQ9wBIB13K/VPeCgICqvHX0vdFZK0qaPAnH6wZo/Wrp9gPMmGJhccxjAbN74HpykmoFKoBRa9fuCZWrGXWUhQZyHWuAABn4u+DDLAMlbLKDHuqE9s6uVy3ajsSSmOEIK3pXonmrw/5U4KTEG2UqMbWhuOdqIc0RCm/qVPxK75iQ0of6/2QL6xWDt+SBhuqWyy+SgOEBl1lY1xGzynzdHKKJYraU1nP+FIa4T13H7uqoc2Pd1IH5Cn8M3pdDi+fYCdh3RD1W8xC3vrrCLAlJK4qgkoi+Jc9yFTsi7MRp9+blxPI4rOPpMsT2gIwjvX/KKm2ULGmYNVrRTMRcOSwdv1mlSsdjZ3KOgX9cnaczozgGzUOX210jDPq8OGNMV2QPYU28rEimyT5eQbINozqj07jPnxn32/RIbd97djlv1oUVcJKbdDFroC5RUwX6SjU0pEQXQsbzhOcv6Hf2tFIbF5dyb76UVepM6DcKboGYJ7R+h79TecMz2Fk5mvKmtxaPydbAdENNJaXyfQIpGnZGMO4JaiLUS0ebl1cswwyjKpTifNegp2TGRBjdnUYe52M2w+AEgn8fF1dUehUTOArhvklFehJrrWfKWyOyW34Mw12CYExi6DfykHMZkLMbcg+7NcS2JfBIFsZAv1yKmOWDPkAMpcZ5hipVGze4fm3VjkC6B3KEu7aQFGDOstkwt/L1R/XbqG7/Lz+ZtsR33nZwCW0bzjN0xloG3oIOphOJfUTrU3u/AjjEN6BhJYXIGtEzdh3AL2wh7GOZHBoKpX6Vu3B8IG087hO5aO7ypVjv6nzGByb6Qg+ZB99907M7ib2N659/1EC9qK5O/+J5BxmIk82TmXfhwvvfMKsCOSWT5hG/PI8XiUlt1hsvL1SvVE1FLrsQYkyXsYT6SFIDjQi14d8wMLY0WCLCu6WaA/aXj5Zs1AUR0pDDJhSgzeZGAYm+suD0wwlS8OUztTHh/SbOtpgbm8/DM0AXTxx5xPbrS6jfI/REvpYLvT9fTdXvY6+adJGVhY4EM97r6JCTZejZbE+g+fvQ7+6BRjJXrfLF405ZMmaNj24OSOQrsn5mdWtDTpGkKRD5sNxSC364rqPNU4fl7UISd7cUa9Tyzw0PnFa7tqgWb6/LqRlXyhA50IABEtIO3EKHv89Wh437oiS5cSyuI3JqLraZ8l9y9Fg7Wfo66vT6yzaYc6Kotv51w4C8MXLyENB17mW4lki6uXJ7TrBo8Vt/ay+eTlGpkYg1+H0XtqGQFSmSibHTvsUPqI0m5y5nMqRUt4oerLZHMQCOdGYKteqKJ+fdHi5J6YS74x62tPNaAvFlM+EcIWHPM51n7PsaFVUPeiQg4VpwNOaDWrpxdhdbXv8Wh82bggEofyghK/m78HyGDJYkAVcUUzHyfIakINvrpet4gO6roeb3caJ7qurKniUaZpojwEgup+3w0dwxaYtWwDKxKQZKEFXH9jhSyuVdaH8x0nHw5UgH+zR/hJFk9hXQjFrIaJGwyYqYCtoIqeSOEBLFvdXVTeDpaaLR8zU5Y79iIcfwT7FzBfHU7QxC0aXr/6PfYikuQBPSHRydhoG4Ahvwbq8DR8M6vlWPMG05jlcEIjDN+Z7+wJ1WlE0mrBi0gUVckXPbIHZtUgpchboeKbKvyMqztmCtmok31SOOildDtZlU5gyWq2YAIpXg9wl5TZ7qMoJiw6nY9MEmgsbQZS46o57e0klNnGS8EL5xVb6hSMGUemELA8IUmpUWpteU9lce/nqGkfXKjm0KQMeRgqLpkcyEcB7+7bfGyUkggw1uQeiHEy7bGOtQjlYLgltrvvWX0ObGgJmlHQTb44RpKd2EA4202dC91OMUilSvOIYptdYlj5Ys77zLw+QiOLqKtMV7jjz2Kf2D8PJ1j/H0yIszbwpuPUjI0CanU/yLvKRpGzqDaz8xuAzKqnuFllbtyZAlyaYcD3zgcAEKuN4ul6IYy6eXPPAuBeAxNGs7MxuTh6+kS9xBJf0xPD77oJ74YzMd1WJJ3G0hIOLjRvpPRko3idWp4+p9j2bkLJbaR4JsH0DBCTKQT+V0RWoO2EapZ3iRKivAILnVPe1TdzpO7R"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Product', 'Exception');
        }
    }
    @isTest
    public static void testInsuranceRecommendationServiceGender(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"","Product":"Car","Vehicle_Category":"'+opp.Vehicle_Type__c+'","Fin_Amount":"300000","Balance_Available":"140000","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Product', 'Exception');
        }
    }
    
        @isTest
    public static void testInsuranceRecommendationServiceBorrowerType(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"","age":"45","gender":"Male","Product":"Car","Vehicle_Category":"'+opp.Vehicle_Type__c+'","Fin_Amount":"300000","Balance_Available":"140000","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Product', 'Exception');
        }
    }
    
      @isTest
    public static void testInsuranceRecommendationServiceCategory(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"Female","Product":"Car","Vehicle_Category":"","Fin_Amount":"300000","Balance_Available":"140000","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Product', 'Exception');
        }
    }
    
    @isTest
    public static void testInsuranceRecommendationServiceFinAmnt(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"Male","Product":"Car","Vehicle_Category":"'+opp.Vehicle_Type__c+'","Fin_Amount":"","Balance_Available":"140000","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Product', 'Exception');
        }
    }
    
      @isTest
    public static void testInsuranceRecommendationServiceTenure(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"Male","Product":"Car","Vehicle_Category":"'+opp.Vehicle_Type__c+'","Fin_Amount":"45000","Balance_Available":"140000","Tenure":"","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Product', 'Exception');
        }
    }
    
     @isTest
    public static void testInsuranceRecommendationServiceVariant(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"Male","Product":"Car","Vehicle_Category":"'+opp.Vehicle_Type__c+'","Fin_Amount":"45000","Balance_Available":"140000","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Product', 'Exception');
        }
    }
    
    @isTest
    public static void testInsuranceRecommendationServiceBalAvailable(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"Male","Product":"Car","Vehicle_Category":"'+opp.Vehicle_Type__c+'","Fin_Amount":"45000","Balance_Available":"","Tenure":"4","Agreement_Value":"363000","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Product', 'Exception');
        }
    }
    
     @isTest
    public static void testInsuranceRecommendationServiceAggValue(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"Male","Product":"Car","Vehicle_Category":"'+opp.Vehicle_Type__c+'","Fin_Amount":"45000","Balance_Available":"40000","Tenure":"4","Agreement_Value":"","Motor_Expiry_Date":"2022-06-10","Motor_Premium":"15000"}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Product', 'Exception');
        }
    }
    
      
         @isTest
    public static void testInsuranceRecommendationServiceMotorPrm(){
        
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
          
            String insuranceRecommendationRequest = '{"applicationNo":"'+opp.Application_number__c+'" ,"vehicleId":"1","Variant":"'+opp.Variant__c+'","Borrower_Type":"'+applicant.Applicant_Type__c+'","age":"45","gender":"Male","Product":"Car","Vehicle_Category":"'+opp.Vehicle_Type__c+'","Fin_Amount":"45000","Balance_Available":"40000","Tenure":"4","Agreement_Value":"464563","Motor_Expiry_Date":"2022-03-19","Motor_Premium":""}';
            
            Continuation con = (Continuation)IntegrationEngine.doInsuranceRecommendationCallout(insuranceRecommendationRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"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"}';
            response.setBody(body);          
        response.setStatusCode(200);
          
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
              Test.setContinuationResponse(continuationLabel, response);
            String insuranceRecommendationResponse= (String)IntegrationEngine.processInsuranceRecommendationResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseActual ='{"Application_No":"5432123","Vehicle_ID":"1","Ins_Product":[{"Ins_Product":"HEALTH","Plan_Code":"CHMIFH","Plan_Name":"INDUS FAMILY HEALTH CARE (SA 2L)","Sum_Insured":"200000.00","Premium":"5645.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFQ","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 2L)","Sum_Insured":"200000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"HEALTH","Plan_Code":"CHMIFP","Plan_Name":"INDUS FAMILY HEALTH PLUS (SA 1L)","Sum_Insured":"100000.00","Premium":"8732.00","LHC":"0.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L4Y","Plan_Name":"LI GPA 3L4Y","Sum_Insured":"300000.00","Premium":"3105.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L4Y","Plan_Name":"LI GPA 5L4Y","Sum_Insured":"500000.00","Premium":"3414.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L4Y","Plan_Name":"LI GPA 7L4Y","Sum_Insured":"730000.00","Premium":"4766.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L4Y","Plan_Name":"LI GPA 10L4Y","Sum_Insured":"1030000.00","Premium":"7046.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_3L5Y","Plan_Name":"LI GPA 3L5Y","Sum_Insured":"270000.00","Premium":"3881.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_5L5Y","Plan_Name":"LI GPA 5L5Y","Sum_Insured":"470000.00","Premium":"4269.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_7L5Y","Plan_Name":"LI GPA 7L5Y","Sum_Insured":"730000.00","Premium":"5958.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"},{"Ins_Product":"COMBO","Plan_Code":"LI_GPA_10L5Y","Plan_Name":"LI GPA 10L5Y","Sum_Insured":"1030000.00","Premium":"8809.00","LHC":"2500.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}],"Status_Flag":"Success","Error_Code":"200","Error_Description":""}';
          System.assertEquals(responseActual,insuranceRecommendationResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Product', 'Exception');
        }
    }
}