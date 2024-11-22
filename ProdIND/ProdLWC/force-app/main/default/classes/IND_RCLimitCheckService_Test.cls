/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_ADAuthenticationRequest IND_ADAuthenticationService IND_ADAuthenticationResponse class
History
Date            Author              Comments
-------------------------------------------------------------
10-12-2021      Satyam More       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_RCLimitCheckService_Test {    
    @isTest
    public static void testRCLimitCheckService(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'A ANBU', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c = '234',
                              MobilePhone = '9701498575',
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduserABC40@testorg.com.psdev1');
            insert u;
            
            System.runAs(u){
                
            Opportunity opp = TestDataUtility.createTestOpportunity211(false);
            opp.Application_number__c = 'A11102302288';
                //opp.Total_Funded_Premium__c = '10000';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
                
            InsuranceDetails__c insuranceDetails = TestDataUtility.createInsuranceDetails(false,opp);
            insuranceDetails.Funded_Non_funded__c = 'Funded';
            insuranceDetails.Amount__c = 15000;
			if (Schema.sObjectType.Opportunity.isCreateable()){
                insert insuranceDetails;
            }                
                
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__c;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
             Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
        vc2.Loan_Application__c = applicant.Opportunity__c;
        vc2.Ben_Code__c = 'testveh';
        vc2.Product__c='TW New';
        vc2.Variant__c = 'twowheeler';
        vc2.Product__c = 'Two Wheeler';
        insert vc2;
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'te';
        pd1.Name = vc2.Variant__c;
        pd1.Type__c = 'Model';
        pd1.External_Reference_Id__c = '58568568';
        insert pd1;
                
                Final_Term__c finalTerm = TestDataUtility.createfinalTerm(false,opp);
                if (Schema.sObjectType.Final_Term__c.isCreateable()){
                	insert finalTerm;
            	}
            /*Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c =2;
            insert dlNumberSetting;
            system.debug('Deal Setting'+ dlNumberSetting);
            
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;    
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            dl.Sub_Stage__c = 'test';
            insert dl;   */         
            
            System.debug('insert pd1');
           // String verifyRequest = '{ "Application_No": "AC4969614_85523017724", "Vehicle_Id": "MRBALENO3_V1", "Ben_Code": "BEN000951", "Product": "Two Wheeler" }';
            
            Continuation con = (Continuation)IntegrationEngine.doRCLimitCheckCallout(applicant.Id,loanAppId, 'dealer');
            System.debug('Continuation con' +con);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"O9V0ilOke9HI78UDCvUn5aYezfrQu2V0oM7Kuba4YvV3E06ktIqmhghRj71mXtUY4hdfZ2AJM1UK6dz92k72h0E9y1YG3ymXqIHKu/G5oTaTatM4zeyrt+v8j9/+kBI1gMVta7qPHWrq0chSx/J7NyheQKa8nQMjvWfXPkRpGtjkj/eeILTGWdkpT12l9RVH"}');
            response.setStatusCode(200);
            System.debug('response' +response);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            System.debug('continuationState' +continuationState);
            String callOutResponse;
           
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            callOutResponse= (String)IntegrationEngine.processRCLimitCheckAPIResponse(labels, IntegrationEngine.continuationState);
               System.debug('callOutResponse' +callOutResponse);  
            Test.stopTest();
            
            //String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Check RC Limit","content":[{"No_Of_Proposals_Available":"1","Available_Disbursal_Amount":"10000.00","Pending_Flag":"Y","Payment_To_DSA_Flag":"N"}]}}';
            String responseExpected ='{"body":null,"response":null}';
            //System.assertEquals(responseExpected, callOutResponse);
             
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter Applicant Id');
        }
    }
     
    @isTest
    public static void testRCLimitCheckService1(){
        
        try{   
            
           Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'A ANBU', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c = '234',
                              MobilePhone = '9701498575',
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduserABC40@testorg.com.psdev1');
            insert u;
            system.runAs(u){
            Opportunity opp = TestDataUtility.createTestOpportunity211(false);
            opp.Application_number__c = 'A11102302288';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__c;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
                
                Final_Term__c finalTerm = TestDataUtility.createfinalTerm(false,opp);
                if (Schema.sObjectType.Final_Term__c.isCreateable()){
                	insert finalTerm;
            	}
            
             Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
        vc2.Loan_Application__c = opp.Id;
        vc2.Ben_Code__c = 'BEN000951';
        vc2.Product__c='TW New';
        vc2.Variant__c = 'twowheeler';
        vc2.Product__c = 'Two Wheeler';
        insert vc2;
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'te';
        pd1.Name = vc2.Variant__c;
        pd1.Type__c = 'Model';
        pd1.External_Reference_Id__c = '58568568';
        insert pd1;
    
            
           // String verifyRequest = '{ "Application_No": "AC4969614_85523017724", "Vehicle_Id": "MRBALENO3_V1", "Ben_Code": "BEN000951", "Product": "Two Wheeler" }';
            
            Continuation con = (Continuation)IntegrationEngine.doRCLimitCheckCalloutForDSAOrDealer(applicant.Id,loanAppId,'Dealer','dealer');
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"O9V0ilOke9HI78UDCvUn5aYezfrQu2V0oM7Kuba4YvV3E06ktIqmhghRj71mXtUY4hdfZ2AJM1UK6dz92k72h0E9y1YG3ymXqIHKu/G5oTaTatM4zeyrt+v8j9/+kBI1gMVta7qPHWrq0chSx/J7NyheQKa8nQMjvWfXPkRpGtjkj/eeILTGWdkpT12l9RVH"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            
            String callOutResponse;
             
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            callOutResponse= (String)IntegrationEngine.processRCLimitCheckAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
             
            //String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Check RC Limit","content":[{"No_Of_Proposals_Available":"1","Available_Disbursal_Amount":"10000.00","Pending_Flag":"Y","Payment_To_DSA_Flag":"N"}]}}';
            String responseExpected ='{"body":null,"response":null}';
            System.assertEquals(responseExpected, callOutResponse);
            }
        } catch(Exception ex){
          //  System.assertEquals(ex.getMessage(),'Please enter Applicant Id');
        }
    }
    @isTest
    public static void testRCLimitCheckService2(){
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'A ANBU', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c = '234',
                              MobilePhone = '9701498575',
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduserABC40@testorg.com.psdev1');
            insert u;
            system.runAs(u){
            Opportunity opp = TestDataUtility.createTestOpportunity211(false);
            opp.Application_number__c = 'A11102302288';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__c;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
                
               /* Final_Term__c finalTerm = TestDataUtility.createfinalTerm(false,opp);
                if (Schema.sObjectType.Final_Term__c.isCreateable()){
                	insert finalTerm;
            	}*/
            
        Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
        vc2.Loan_Application__c = opp.Id;
        vc2.Ben_Code__c = 'BEN000951';
        vc2.Product__c='TW New';
        vc2.Variant__c = 'twowheeler';
        vc2.Product__c = 'Two Wheeler';
        insert vc2;
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'te';
        pd1.Name = vc2.Variant__c;
        pd1.Type__c = 'Model';
        pd1.External_Reference_Id__c = '58568568';
        insert pd1;
         
           // String verifyRequest = '{ "Application_No": "AC4969614_85523017724", "Vehicle_Id": "MRBALENO3_V1", "Ben_Code": "BEN000951", "Product": "Two Wheeler" }';
                
            Continuation con = (Continuation)IntegrationEngine.doRCLimitCheckCallout(applicant.Id,loanAppId, 'dealer'); 
           
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"O9V0ilOke9HI78UDCvUn5aYezfrQu2V0oM7Kuba4YvV3E06ktIqmhghRj71mXtUY4hdfZ2AJM1UK6dz92k72h0E9y1YG3ymXqIHKu/G5oTaTatM4zeyrt+v8j9/+kBI1gMVta7qPHWrq0chSx/J7NyheQKa8nQMjvWfXPkRpGtjkj/eeILTGWdkpT12l9RVH"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            
            String callOutResponse;
             
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            callOutResponse= (String)IntegrationEngine.processRCLimitCheckAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
             
            //String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Check RC Limit","content":[{"No_Of_Proposals_Available":"1","Available_Disbursal_Amount":"10000.00","Pending_Flag":"Y","Payment_To_DSA_Flag":"N"}]}}';
            String responseExpected ='{"body":null,"response":null}';
            System.assertEquals(responseExpected, callOutResponse);
            }
        }catch(Exception ex){
           System.assertEquals(ex.getMessage(),'Please enter finance amount');
        }
            
        }
     @isTest
    public static void testRCLimitCheckService3(){
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'A ANBU', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c = '234',
                              MobilePhone = '9701498575',
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduserABC40@testorg.com.psdev1');
            insert u;
            system.runAs(u){
            Opportunity opp = TestDataUtility.createTestOpportunity211(false);
            opp.Application_number__c = 'A11102302288';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__c;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
                
               /* Final_Term__c finalTerm = TestDataUtility.createfinalTerm(false,opp);
                if (Schema.sObjectType.Final_Term__c.isCreateable()){
                	insert finalTerm;
            	}*/
            
        Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
        vc2.Loan_Application__c = opp.Id;
        vc2.Ben_Code__c = 'BEN000951';
        vc2.Product__c='TW New';
        vc2.Variant__c = 'twowheeler';
        vc2.Product__c = 'Two Wheeler';
        insert vc2;
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'te';
        pd1.Name = vc2.Variant__c;
        pd1.Type__c = 'Model';
        pd1.External_Reference_Id__c = '58568568';
        insert pd1;
         
           // String verifyRequest = '{ "Application_No": "AC4969614_85523017724", "Vehicle_Id": "MRBALENO3_V1", "Ben_Code": "BEN000951", "Product": "Two Wheeler" }';
             Continuation con = (Continuation)IntegrationEngine.doRCLimitCheckCalloutForDSAOrDealer(applicant.Id,loanAppId,'dealer','dealer'); 
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"O9V0ilOke9HI78UDCvUn5aYezfrQu2V0oM7Kuba4YvV3E06ktIqmhghRj71mXtUY4hdfZ2AJM1UK6dz92k72h0E9y1YG3ymXqIHKu/G5oTaTatM4zeyrt+v8j9/+kBI1gMVta7qPHWrq0chSx/J7NyheQKa8nQMjvWfXPkRpGtjkj/eeILTGWdkpT12l9RVH"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            
            String callOutResponse;
             
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            callOutResponse= (String)IntegrationEngine.processRCLimitCheckAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
             
            //String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Check RC Limit","content":[{"No_Of_Proposals_Available":"1","Available_Disbursal_Amount":"10000.00","Pending_Flag":"Y","Payment_To_DSA_Flag":"N"}]}}';
            String responseExpected ='{"body":null,"response":null}';
            System.assertEquals(responseExpected, callOutResponse);
            }
        }catch(Exception ex){
           System.assertEquals(ex.getMessage(),'Please enter finance amount');
        }
            
    }     
}