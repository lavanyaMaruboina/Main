/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_CarwalePricesRequest IND_CarwalePricesService IND_CarwalePricesResponse class
History
Date            Author              Comments
-------------------------------------------------------------
21-12-2021      Satyam More       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_CarwalePricesService_Test {
    @testSetup
    static void setup(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];//IBL CVO
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,User_Id__c = '29927_MO',
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123Pro@indusbank.com',mobilePhone= '9087567898');
        insert u;
    }
    @isTest
    public static void testCarwalePricesService(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
                              Maker_Id__c = '1002',User_Id__c = '29927_MO',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
            system.runAs(u){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                opp.Product_type__c = 'Passenger Vehicles';
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String carwalePricesRequest = '{"vehicleType":"'+opp.Vehicle_Type__c+'" ,"CityId":"176","VariantCode":"'+opp.Variant__c+'","leadId":"'+opp.Lead_number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doCarwalePricesCallout(carwalePricesRequest,opp.Product_Type__c);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('          bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngrhpKtx9GYnOE9qR1zv63H6zG/JeivAvyRbNvkjMRr5+C3Bq1WjjawB/9Do6jzaGO5nYL7rTuwqNPstJATSEKA9/TPhTZoTKVf+zDPN5kcWu3OIJ1CkSuNeYc3ZZ2YvXrvt+KCqxJNl3zKrJj4FMBszhn8el7l1dcq1XPmLt34wuEXyblwVa1q/HkzppCXxX7G5oNeCwUsv0y7TUFR61K1br6+W0ZxjdeSE/j7wvxPrh6FhiCSNs2H/M9yoKMsOi+oi2UspHzYEN1OS8zJ9g0mxRxUgUOYHFItOYx6xXt5JikNJkmuHQz9ZzWb5TA+jQp/BcmJKPLhoyax2NeZQGy2Kj1tm7YG853GUxMaczj5YKreRXPpvsyyZBGjJsiuQvzB0/FeyiVRKmqBURimZGcsKXAZPHDQ24tWhP5WQFUOuZNE3etJ0YB5D2EotSK7q2bqdtMuqQzlC6D1sjKcEcfanK6bKbjFOnGO7FC52hqZlQ==  ');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            
            String carwalePricesCallOutResponse;
            
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                carwalePricesCallOutResponse= (String)IntegrationEngine.processCarwalePricesResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            
                String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"","content":[{"pricesList":[{"value":698000,"type":1,"name":"Ex-Showroom Price","id":2},{"value":69800,"type":1,"name":"RTO","id":3},{"value":2950,"type":1,"name":"Road Safety Tax","id":88},{"value":59355,"type":1,"name":"Insurance","id":5},{"value":600,"type":1,"name":"FASTag","id":117}],"nearByCityName":"","nearByCityId":0,"isMetallic":false}]}}';
                System.assertEquals(responseActual,carwalePricesCallOutResponse, 'SUCCESS');
            } 
            } catch(Exception ex){
                //System.assertEquals(ex.getMessage(),'Script-thrown exception');
            }
        }
        
        @isTest
        public static void testCarwalePricesService2(){
            
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
                String carwalePricesRequest = '{"vehicleType":"" ,"CityId":"176","VariantCode":"'+opp.Variant__c+'","leadId":"'+opp.Lead_number__c+'"}';
                
                Continuation con = (Continuation)IntegrationEngine.doCarwalePricesCallout(carwalePricesRequest,'Two Wheeler');
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('          bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngrhpKtx9GYnOE9qR1zv63H6zG/JeivAvyRbNvkjMRr5+C3Bq1WjjawB/9Do6jzaGO5nYL7rTuwqNPstJATSEKA9/TPhTZoTKVf+zDPN5kcWu3OIJ1CkSuNeYc3ZZ2YvXrvt+KCqxJNl3zKrJj4FMBszhn8el7l1dcq1XPmLt34wuEXyblwVa1q/HkzppCXxX7G5oNeCwUsv0y7TUFR61K1br6+W0ZxjdeSE/j7wvxPrh6FhiCSNs2H/M9yoKMsOi+oi2UspHzYEN1OS8zJ9g0mxRxUgUOYHFItOYx6xXt5JikNJkmuHQz9ZzWb5TA+jQp/BcmJKPLhoyax2NeZQGy2Kj1tm7YG853GUxMaczj5YKreRXPpvsyyZBGjJsiuQvzB0/FeyiVRKmqBURimZGcsKXAZPHDQ24tWhP5WQFUOuZNE3etJ0YB5D2EotSK7q2bqdtMuqQzlC6D1sjKcEcfanK6bKbjFOnGO7FC52hqZlQ==  ');
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String carwalePricesCallOutResponse= (String)IntegrationEngine.processCarwalePricesResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"","content":[{"pricesList":[{"value":698000,"type":1,"name":"Ex-Showroom Price","id":2},{"value":69800,"type":1,"name":"RTO","id":3},{"value":2950,"type":1,"name":"Road Safety Tax","id":88},{"value":59355,"type":1,"name":"Insurance","id":5},{"value":600,"type":1,"name":"FASTag","id":117}],"nearByCityName":"","nearByCityId":0,"isMetallic":false}]}}';
                System.assertEquals(responseActual,carwalePricesCallOutResponse, 'SUCCESS');
                
            } catch(Exception ex){
                //System.assertEquals(ex.getMessage(),System.Label.VehicleType, 'Exception');
            }
        }
        
        
        
        @isTest
        public static void testCarwalePricesService3(){
            
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
                String carwalePricesRequest = '{"vehicleType":"'+opp.Vehicle_Type__c+'" ,"CityId":"176","VariantCode":"","leadId":"'+opp.Lead_number__c+'"}';
                
                Continuation con = (Continuation)IntegrationEngine.doCarwalePricesCallout(carwalePricesRequest,'Two Wheeler');
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('          bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngrhpKtx9GYnOE9qR1zv63H6zG/JeivAvyRbNvkjMRr5+C3Bq1WjjawB/9Do6jzaGO5nYL7rTuwqNPstJATSEKA9/TPhTZoTKVf+zDPN5kcWu3OIJ1CkSuNeYc3ZZ2YvXrvt+KCqxJNl3zKrJj4FMBszhn8el7l1dcq1XPmLt34wuEXyblwVa1q/HkzppCXxX7G5oNeCwUsv0y7TUFR61K1br6+W0ZxjdeSE/j7wvxPrh6FhiCSNs2H/M9yoKMsOi+oi2UspHzYEN1OS8zJ9g0mxRxUgUOYHFItOYx6xXt5JikNJkmuHQz9ZzWb5TA+jQp/BcmJKPLhoyax2NeZQGy2Kj1tm7YG853GUxMaczj5YKreRXPpvsyyZBGjJsiuQvzB0/FeyiVRKmqBURimZGcsKXAZPHDQ24tWhP5WQFUOuZNE3etJ0YB5D2EotSK7q2bqdtMuqQzlC6D1sjKcEcfanK6bKbjFOnGO7FC52hqZlQ==  ');
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String carwalePricesCallOutResponse= (String)IntegrationEngine.processCarwalePricesResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"","content":[{"pricesList":[{"value":698000,"type":1,"name":"Ex-Showroom Price","id":2},{"value":69800,"type":1,"name":"RTO","id":3},{"value":2950,"type":1,"name":"Road Safety Tax","id":88},{"value":59355,"type":1,"name":"Insurance","id":5},{"value":600,"type":1,"name":"FASTag","id":117}],"nearByCityName":"","nearByCityId":0,"isMetallic":false}]}}';
                System.assertEquals(responseActual,carwalePricesCallOutResponse, 'SUCCESS');
                
            } catch(Exception ex){
                //System.assertEquals(ex.getMessage(),System.Label.VarientCode, 'Exception');
            }
        }
        
        @isTest
        public static void testCarwalePricesService4(){
            
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
                String carwalePricesRequest = '{"vehicleType":"'+opp.Vehicle_Type__c+'" ,"CityId":"176","VariantCode":"'+opp.Variant__c+'","leadId":""}';
                
                Continuation con = (Continuation)IntegrationEngine.doCarwalePricesCallout(carwalePricesRequest,'Two Wheeler');
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('          bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngrhpKtx9GYnOE9qR1zv63H6zG/JeivAvyRbNvkjMRr5+C3Bq1WjjawB/9Do6jzaGO5nYL7rTuwqNPstJATSEKA9/TPhTZoTKVf+zDPN5kcWu3OIJ1CkSuNeYc3ZZ2YvXrvt+KCqxJNl3zKrJj4FMBszhn8el7l1dcq1XPmLt34wuEXyblwVa1q/HkzppCXxX7G5oNeCwUsv0y7TUFR61K1br6+W0ZxjdeSE/j7wvxPrh6FhiCSNs2H/M9yoKMsOi+oi2UspHzYEN1OS8zJ9g0mxRxUgUOYHFItOYx6xXt5JikNJkmuHQz9ZzWb5TA+jQp/BcmJKPLhoyax2NeZQGy2Kj1tm7YG853GUxMaczj5YKreRXPpvsyyZBGjJsiuQvzB0/FeyiVRKmqBURimZGcsKXAZPHDQ24tWhP5WQFUOuZNE3etJ0YB5D2EotSK7q2bqdtMuqQzlC6D1sjKcEcfanK6bKbjFOnGO7FC52hqZlQ==  ');
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String carwalePricesCallOutResponse= (String)IntegrationEngine.processCarwalePricesResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"","content":[{"pricesList":[{"value":698000,"type":1,"name":"Ex-Showroom Price","id":2},{"value":69800,"type":1,"name":"RTO","id":3},{"value":2950,"type":1,"name":"Road Safety Tax","id":88},{"value":59355,"type":1,"name":"Insurance","id":5},{"value":600,"type":1,"name":"FASTag","id":117}],"nearByCityName":"","nearByCityId":0,"isMetallic":false}]}}';
                System.assertEquals(responseActual,carwalePricesCallOutResponse, 'SUCCESS');
                
            } catch(Exception ex){
                //System.assertEquals(ex.getMessage(),System.Label.LeadId, 'Exception');
            }
        }
        
        @isTest
        public static void testCarwalePricesService5(){
            
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
                
                String carwalePricesRequest = '{"vehicleType":"'+opp.Vehicle_Type__c+'" ,"CityId":"","VariantCode":"'+opp.Variant__c+'","leadId":"'+opp.Lead_number__c+'"}';
                
                Continuation con = (Continuation)IntegrationEngine.doCarwalePricesCallout(carwalePricesRequest,'Two Wheeler');
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('          bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngrhpKtx9GYnOE9qR1zv63H6zG/JeivAvyRbNvkjMRr5+C3Bq1WjjawB/9Do6jzaGO5nYL7rTuwqNPstJATSEKA9/TPhTZoTKVf+zDPN5kcWu3OIJ1CkSuNeYc3ZZ2YvXrvt+KCqxJNl3zKrJj4FMBszhn8el7l1dcq1XPmLt34wuEXyblwVa1q/HkzppCXxX7G5oNeCwUsv0y7TUFR61K1br6+W0ZxjdeSE/j7wvxPrh6FhiCSNs2H/M9yoKMsOi+oi2UspHzYEN1OS8zJ9g0mxRxUgUOYHFItOYx6xXt5JikNJkmuHQz9ZzWb5TA+jQp/BcmJKPLhoyax2NeZQGy2Kj1tm7YG853GUxMaczj5YKreRXPpvsyyZBGjJsiuQvzB0/FeyiVRKmqBURimZGcsKXAZPHDQ24tWhP5WQFUOuZNE3etJ0YB5D2EotSK7q2bqdtMuqQzlC6D1sjKcEcfanK6bKbjFOnGO7FC52hqZlQ==  ');
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String carwalePricesCallOutResponse= (String)IntegrationEngine.processCarwalePricesResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"","content":[{"pricesList":[{"value":698000,"type":1,"name":"Ex-Showroom Price","id":2},{"value":69800,"type":1,"name":"RTO","id":3},{"value":2950,"type":1,"name":"Road Safety Tax","id":88},{"value":59355,"type":1,"name":"Insurance","id":5},{"value":600,"type":1,"name":"FASTag","id":117}],"nearByCityName":"","nearByCityId":0,"isMetallic":false}]}}';
                System.assertEquals(responseActual,carwalePricesCallOutResponse, 'SUCCESS');
                
            } catch(Exception ex){
                //System.assertEquals(ex.getMessage(),System.Label.CityId, 'Exception');
            }
        }
        
      /*  @isTest
        public static void testCarwalePricesService6(){
            
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
                
                String carwalePricesRequest = '{"vehicleType":"'+opp.Vehicle_Type__c+'" ,"CityId":"176","VariantCode":"'+opp.Variant__c+'","leadId":"'+opp.Lead_number__c+'"}';
                
                Continuation con = (Continuation)IntegrationEngine.doCarwalePricesCallout(carwalePricesRequest);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('          bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngrhpKtx9GYnOE9qR1zv63H6zG/JeivAvyRbNvkjMRr5+C3Bq1WjjawB/9Do6jzaGO5nYL7rTuwqNPstJATSEKA9/TPhTZoTKVf+zDPN5kcWu3OIJ1CkSuNeYc3ZZ2YvXrvt+KCqxJNl3zKrJj4FMBszhn8el7l1dcq1XPmLt34wuEXyblwVa1q/HkzppCXxX7G5oNeCwUsv0y7TUFR61K1br6+W0ZxjdeSE/j7wvxPrh6FhiCSNs2H/M9yoKMsOi+oi2UspHzYEN1OS8zJ9g0mxRxUgUOYHFItOYx6xXt5JikNJkmuHQz9ZzWb5TA+jQp/BcmJKPLhoyax2NeZQGy2Kj1tm7YG853GUxMaczj5YKreRXPpvsyyZBGjJsiuQvzB0/FeyiVRKmqBURimZGcsKXAZPHDQ24tWhP5WQFUOuZNE3etJ0YB5D2EotSK7q2bqdtMuqQzlC6D1sjKcEcfanK6bKbjFOnGO7FC52hqZlQ==  ');
                response.setStatusCode(500);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String carwalePricesCallOutResponse= (String)IntegrationEngine.processCarwalePricesResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"","content":[{"pricesList":[{"value":698000,"type":1,"name":"Ex-Showroom Price","id":2},{"value":69800,"type":1,"name":"RTO","id":3},{"value":2950,"type":1,"name":"Road Safety Tax","id":88},{"value":59355,"type":1,"name":"Insurance","id":5},{"value":600,"type":1,"name":"FASTag","id":117}],"nearByCityName":"","nearByCityId":0,"isMetallic":false}]}}';
                System.assertEquals(responseActual,carwalePricesCallOutResponse, 'SUCCESS');
                
            } catch(Exception ex){
                System.assertEquals(ex.getMessage(),'Please enter the Maker Id', 'Exception');
            }
        } */
    
    @isTest
    public static void testCarwalePricesService7(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
                              Maker_Id__c = '1002',User_Id__c = '29927_MO',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
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
            
            String carwalePricesRequest = '{"vehicleType":"'+opp.Vehicle_Type__c+'" ,"CityId":"176","VariantCode":"'+opp.Variant__c+'","leadId":"'+opp.Lead_number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doCarwalePricesCallout(carwalePricesRequest,'Two Wheeler');
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('          bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngrhpKtx9GYnOE9qR1zv63H6zG/JeivAvyRbNvkjMRr5+C3Bq1WjjawB/9Do6jzaGO5nYL7rTuwqNPstJATSEKA9/TPhTZoTKVf+zDPN5kcWu3OIJ1CkSuNeYc3ZZ2YvXrvt+KCqxJNl3zKrJj4FMBszhn8el7l1dcq1XPmLt34wuEXyblwVa1q/HkzppCXxX7G5oNeCwUsv0y7TUFR61K1br6+W0ZxjdeSE/j7wvxPrh6FhiCSNs2H/M9yoKMsOi+oi2UspHzYEN1OS8zJ9g0mxRxUgUOYHFItOYx6xXt5JikNJkmuHQz9ZzWb5TA+jQp/BcmJKPLhoyax2NeZQGy2Kj1tm7YG853GUxMaczj5YKreRXPpvsyyZBGjJsiuQvzB0/FeyiVRKmqBURimZGcsKXAZPHDQ24tWhP5WQFUOuZNE3etJ0YB5D2EotSK7q2bqdtMuqQzlC6D1sjKcEcfanK6bKbjFOnGO7FC52hqZlQ==  ');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            
            String carwalePricesCallOutResponse;
            
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                carwalePricesCallOutResponse= (String)IntegrationEngine.processCarwalePricesResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            
                String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"","content":[{"pricesList":[{"value":698000,"type":1,"name":"Ex-Showroom Price","id":2},{"value":69800,"type":1,"name":"RTO","id":3},{"value":2950,"type":1,"name":"Road Safety Tax","id":88},{"value":59355,"type":1,"name":"Insurance","id":5},{"value":600,"type":1,"name":"FASTag","id":117}],"nearByCityName":"","nearByCityId":0,"isMetallic":false}]}}';
                System.assertEquals(responseActual,carwalePricesCallOutResponse, 'SUCCESS');
            } 
            } catch(Exception ex){
                //System.assertEquals(ex.getMessage(),'No Response Found.');
            }
        }
    
    @isTest
    public static void testone(){
         
        Opportunity opgt1 = new Opportunity();
                opgt1.StageName = 'Qualification';
                opgt1.CloseDate = Date.newInstance(2021, 1, 11);
                opgt1.Name = 'testone';
                insert opgt1;
                
                Applicant__c apgt1 = new Applicant__c();
                apgt1.Opportunity__c = opgt1.Id;
                apgt1.Contact_number__c = '9743514830';
                apgt1.Applicant_Type__c = 'Borrower';
                insert apgt1;
        
                Income_Details__c idt1 = new Income_Details__c();
                idt1.Applicant__c = apgt1.Id;
                idt1.API_Transaction_Status__c = 'testapi';
                idt1.Bank_Account_Number__c = '32543409214';
                idt1.Client_Transaction_Id__c = 'testclient';
                idt1.Remarks__c = 'no comments';
                insert idt1;
            
                RequestWrapper rw1 = new RequestWrapper();
                rw1.applicantId = apgt1.Id;
                rw1.panNumber = apgt1.PAN_No__c;
                rw1.firstName = 'testone';
                rw1.lastName = 'testlast';
                rw1.dealNumber = 'testdl';
                rw1.dateOfBirth = '23061994';
                rw1.telephoneNumber = '9999999999';
                rw1.kycNo = '4635643';
                rw1.kycPassportFileNo = 'pt23556';
                rw1.kycGender = 'male';
                rw1.kycPassportNo = '232041';
                rw1.leadId = '676476368';
                rw1.email = 'test@gmail.com';
                rw1.income = '200000';
                rw1.aadhaarNo = '56678862431';
                rw1.dOB = Datetime.newInstance(1994, 6, 23, 12, 30, 0);
                rw1.vehicleRegisterationNumber = 'ap 26 1234';
                rw1.loanApplicationId = opgt1.Id;
                rw1.noOfCoborrowers = '8';
                rw1.vehicleType = 'TwoWheelers';
                rw1.CityId = '26';
                rw1.VariantCode = 'test123';
                rw1.customerCode = 'samplle123';
                rw1.oldDealNo = 'test453';
                rw1.nocNo = '45545667';
                rw1.product = 'testprd';
                rw1.category = 'motor';
                rw1.subCategory = 'testsub';
                rw1.applicantId = 'testapid';
                rw1.cicNo = '1234';
                rw1.emailTo = 'samplw@gmail.com';
                rw1.emailCC = 'testcc@gmail.com';
                rw1.emailSubject = 'testclass';
                rw1.emailBody = 'testbody';
                rw1.loanAmount = '1500000';
                rw1.loanDuration = '60';
                rw1.loanType = 'Personal';
                rw1.processingType = 'typeone';
                rw1.acceptancePolicy = 'test';
                rw1.uploadingScannedStatements = 'docs';
                rw1.yearMonthFrom = '6';
                rw1.yearMonthTo = '10';
                rw1.productType = 'vehicle';
                rw1.employmentType = 'permenant';
                rw1.employerName = 'dhoni';
                rw1.fileId = 'testfield';
                rw1.institutionId = '23';
                rw1.password = '12345';
                rw1.perfiosTransactionId = 'testper';
                rw1.uid = '134455';
                rw1.otp = '764345';
                rw1.txn = '4566633445';
                rw1.rnn = 'testrnn';
                rw1.applicantFirstName = 'mahi';
                rw1.applicantMiddleName = 'singh';
                rw1.applicantLastName = 'dhoni';
                rw1.name = 'name';
                rw1.destinationName = 'ap';
                rw1.destinationNames = 'ap';
                rw1.cinNo = 'testcin';
                rw1.applicationNo = '134355544655';
                rw1.vehicleId = 'v34566';
                rw1.age = '26';
                rw1.gender = 'male';
                rw1.insProduct = 'testprd';
                rw1.planCode = 'testplan';
                rw1.Fin_Amount = '50000';
                rw1.tenure = '36';
                rw1.dealNumber = 'Insurance Premium';
                rw1.Borrower_Type = 'Insurance Recommendation';
                rw1.Vehicle_Category = 'Insurance Recommendation';
                rw1.Variant = 'Insurance Recommendation';
                rw1.Fin_Amount = '1000';
                rw1.Balance_Available = '100';
                rw1.Agreement_Value = '10000';
                rw1.Motor_Expiry_Date = '2023-12-11';
                rw1.Motor_Premium = '1000';
                rw1.coBorrowerPanNumber = 'BTWSA3241J';
                rw1.coBorrowerDob = datetime.newInstance(1995, 9, 15, 12, 30, 0);
                rw1.coBorrowerIncome = '200000';
                rw1.coBorrowerCinNo = '3445666';
                rw1.contactNumber = '8888888888';
                rw1.otpForBorrower = '345643';
                rw1.flag = 'testflag';
                rw1.valuerCategory = 'tetsvaluer';
                rw1.placeOfInspection = 'city';
                rw1.locationOfVehicle = 'ap';
                rw1.city = 'nellore';
                rw1.state = 'ap';
                rw1.incomeDtlId = idt1.Id;
                rw1.gstType = 'testgst';
                rw1.itrType = 'testitr';
                rw1.bankType = 'national';
                rw1.GstNumber = 'g667438383883';
                rw1.kycDOB = Date.newInstance(1995, 9, 15);
                rw1.year = '2020';
                rw1.month = '6';
                rw1.stateCode = '29';
                rw1.color = 'red';
                rw1.owner = 'testowner';
                rw1.kilometer = '200';
                rw1.incomeDetailId = idt1.Id;
                rw1.incomeDetails = idt1;
                rw1.whatsappNo = '7777777777';
                rw1.reportType = 'Account';
                rw1.enachStatus = 'testenach';
                rw1.contentId = 'con1234';
                rw1.crmIrrRequested = 'testcrm123';
                rw1.exShowroomPrice = '40000';
                rw1.onRoadPrice = '70000';
                rw1.finalTermId = 'testfinal';
                rw1.fundingOnExShowroom = '4000';
                rw1.fundingOnORP = 'teston';
                rw1.currentScreen = 'testscreen';
                rw1.sumOfFundedInsurance = '40000';
                rw1.riskBand = 'testrisk';
                rw1.borrowerNIP = 'testnip';
                rw1.coBorrowerNIP = 'conip';
                rw1.borrowerPresentAddress = 'testadd';
                rw1.coBorrowerPresentAddress = 'testcoadd';
                rw1.emi = '1000';
                rw1.subProduct = 'testsub';
                rw1.thresholdNetIRR = 'testirr';
        
        User u = [Select id from user where username = 'test_userprod123Pro@indusbank.com' limit 1];
        Test.startTest();
        System.runAs(u){
            IND_CarwalePricesRequest pr1 = new IND_CarwalePricesRequest(rw1,opgt1.Id);
            Map<String,String> pr2 = pr1.getHttpRequestHeaders();
            IND_CarwalePricesService.getCarwalePricesCallOutRequest(rw1,opgt1.Id);


        }
        Test.stopTest();
    }
    
     @isTest
    public static void testExceptionHandling(){
        // Mocking the inputs that will cause an exception
        RequestWrapper requestWrapper = new RequestWrapper(); // Provide necessary values
        String loanAppId = 'Test Loan App Id';
        
        // Use Test.startTest() and Test.stopTest() to ensure proper handling of async operations
        Test.startTest();
        // Call the method that is expected to throw an exception
        try {
            IND_CarwalePricesService.getCarwalePricesCallOutRequest(requestWrapper, loanAppId);
            // If the exception is not thrown, fail the test
            System.assert(false, 'Exception should have been thrown.');
        } catch (IND_Exception ex) {
            // Verify that the exception message is correct
            //System.assertEquals('Expected exception message', ex.getMessage());
            // Optionally, you can add more assertions based on your requirements
        }
        Test.stopTest();
    }
    }