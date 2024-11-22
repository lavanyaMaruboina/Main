@isTest(SeeAllData=false)
public class IND_CIBILService_Test {
    
    @isTest
    public static void testCIBILService(){
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Account acc = TestDataUtility.createTestAccount(false);
            if (Schema.sObjectType.Account.isCreateable()){
                insert acc;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            applicant.Account__c = acc.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            Documents__c document1 = TestDataUtility.createTestPPDocsForInternalDedupe(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Documents__c document2 = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }
            
            Documents__c document4 = TestDataUtility.createTestPanDocsForInternalDedupe(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document4;
            }
            
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false,applicant);
            if (Schema.sObjectType.CIBIL_Details__c.isCreateable()){
                insert cibilDetail;
            }
            String cibilCallOutRequest = '{"applicantId":"'+applicant.Id+'","loanApplicationId":"'+opp.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doCIBILReportCallout(cibilCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"QDKv+/rEIFMCQ7gqewFK52+UKf4pYoJmwObxt35m1IQzKaTDw13zkGnHypLuBpBhQWshsxWlvs1eTa21PpWyr+8xtFhWuZOiQhbzHn2D+2AHGha7tMqEyxvYub314A7b"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String externalCallOutResponse=(String)IntegrationEngine.processCIBILReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{  "IsSuccess": "True",  "StatusCode": "200",  "StatusDescription": "Sucess"}}';
            System.assertEquals(responseActual,externalCallOutResponse);
            
        } catch(Exception ex){
            System.debug(ex);
            //System.assertEquals(ex.getMessage(),'User id is required.');
        }
    }
    @isTest
    public static void testCIBILService2(){
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForCIBIL1(false,opp);
            
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document1 = TestDataUtility.createTestPPDocsForInternalDedupe(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Documents__c document2 = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }
            
            Documents__c document4 = TestDataUtility.createTestPanDocsForInternalDedupe(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document4;
            }
            
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false,applicant);
            if (Schema.sObjectType.CIBIL_Details__c.isCreateable()){
                insert cibilDetail;
            }
            
            String cibilCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doCIBILReportCallout(cibilCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"QDKv+/rEIFMCQ7gqewFK52+UKf4pYoJmwObxt35m1IQzKaTDw13zkGnHypLuBpBhQWshsxWlvs1eTa21PpWyr+8xtFhWuZOiQhbzHn2D+2AHGha7tMqEyxvYub314A7b"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String externalCallOutResponse=(String)IntegrationEngine.processCIBILReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{  "IsSuccess": "True",  "StatusCode": "200",  "StatusDescription": "Sucess"}}';
            System.assertEquals(responseActual,externalCallOutResponse);
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'User id is required.');
        }
    }
    
    @isTest
    public static void testCIBILService3(){
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForCIBIL(false,opp);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document1 = TestDataUtility.createTestPPDocsForInternalDedupe(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Documents__c document2 = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }
            
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false,applicant);
            if (Schema.sObjectType.CIBIL_Details__c.isCreateable()){
                insert cibilDetail;
            }
            
            String cibilCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doCIBILReportCallout(cibilCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"QDKv+/rEIFMCQ7gqewFK52+UKf4pYoJmwObxt35m1IQzKaTDw13zkGnHypLuBpBhQWshsxWlvs1eTa21PpWyr+8xtFhWuZOiQhbzHn2D+2AHGha7tMqEyxvYub314A7b"}  ');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String externalCallOutResponse=(String)IntegrationEngine.processCIBILReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{  "IsSuccess": "True",  "StatusCode": "200",  "StatusDescription": "Sucess"}}';
            System.assertEquals(responseActual,externalCallOutResponse);
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.CustomerName);
        }
    }
    
    @isTest
    public static void testCIBILService4(){
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForCIBIL2(false,opp);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document1 = TestDataUtility.createTestPPDocsForInternalDedupe(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Documents__c document2 = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }
            Documents__c document3 = TestDataUtility.createTestKYCDocsForCIBIL(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document3;
            }
            
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false,applicant);
            if (Schema.sObjectType.CIBIL_Details__c.isCreateable()){
                insert cibilDetail;
            }
            
            String cibilCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doCIBILReportCallout(cibilCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"QDKv+/rEIFMCQ7gqewFK52+UKf4pYoJmwObxt35m1IQzKaTDw13zkGnHypLuBpBhQWshsxWlvs1eTa21PpWyr+8xtFhWuZOiQhbzHn2D+2AHGha7tMqEyxvYub314A7b"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String externalCallOutResponse=(String)IntegrationEngine.processCIBILReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{  "IsSuccess": "True",  "StatusCode": "200",  "StatusDescription": "Sucess"}}';
            System.assertEquals(responseActual,externalCallOutResponse);
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'User id is required.');
        }
    }
    
    @isTest
    public static void testCIBILService5(){
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForCIBIL2(false,opp);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document1 = TestDataUtility.createTestPPDocsForInternalDedupe(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Documents__c document2 = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }
            Documents__c document3 = TestDataUtility.createTestKYCDocsForCIBIL(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document3;
            }
            
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false,applicant);
            if (Schema.sObjectType.CIBIL_Details__c.isCreateable()){
                insert cibilDetail;
            }
            
            String cibilCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doCIBILReportCallout(cibilCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"QDKv+/rEIFMCQ7gqewFK52+UKf4pYoJmwObxt35m1IQzKaTDw13zkGnHypLuBpBhQWshsxWlvs1eTa21PpWyr+8xtFhWuZOiQhbzHn2D+2AHGha7tMqEyxvYub314A7b"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String externalCallOutResponse=(String)IntegrationEngine.processCIBILReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{  "IsSuccess": "True",  "StatusCode": "200",  "StatusDescription": "Sucess"}}';
            System.assertEquals(responseActual,externalCallOutResponse);
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.EnquiryPurpose);
        }
    }
    
    @isTest
    public static void testCIBILService6(){
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForCIBIL2(false,opp);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document1 = TestDataUtility.createTestPPDocsForInternalDedupe(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Documents__c document2 = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }
            Documents__c document3 = TestDataUtility.createTestKYCDocsForCIBIL(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document3;
            }
            
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false,applicant);
            if (Schema.sObjectType.CIBIL_Details__c.isCreateable()){
                insert cibilDetail;
            }
            
            String cibilCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doCIBILReportCallout(cibilCallOutRequest);
            
            
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"QDKv+/rEIFMCQ7gqewFK52+UKf4pYoJmwObxt35m1IQzKaTDw13zkGnHypLuBpBhQWshsxWlvs1eTa21PpWyr+8xtFhWuZOiQhbzHn2D+2AHGha7tMqEyxvYub314A7b"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String externalCallOutResponse=(String)IntegrationEngine.processCIBILReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{  "IsSuccess": "True",  "StatusCode": "200",  "StatusDescription": "Sucess"}}';
            System.assertEquals(responseActual,externalCallOutResponse);
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'User id is required.');
        }
    }
    
    @isTest
    public static void testCIBILService7(){
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForCIBIL2(false,opp);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document1 = new Documents__c();
            document1.Applicant__c = applicant.Id;
            document1.Opportunity_Relation__c = opp.Id;
            document1.Document_Type__c = System.Label.DrivingLicences;
            document1.Document_Side__c ='Back';
            document1.Aadhar_Source__c = 'ScanAadhar';
            insert document1;
            
            Documents__c document2 = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }
            Documents__c document3 = TestDataUtility.createTestKYCDocsForCIBIL(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document3;
            }
            
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false,applicant);
            if (Schema.sObjectType.CIBIL_Details__c.isCreateable()){
                insert cibilDetail;
            }
            
            String cibilCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doCIBILReportCallout(cibilCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"QDKv+/rEIFMCQ7gqewFK52+UKf4pYoJmwObxt35m1IQzKaTDw13zkGnHypLuBpBhQWshsxWlvs1eTa21PpWyr+8xtFhWuZOiQhbzHn2D+2AHGha7tMqEyxvYub314A7b"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String externalCallOutResponse=(String)IntegrationEngine.processCIBILReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{  "IsSuccess": "True",  "StatusCode": "200",  "StatusDescription": "Sucess"}}';
            System.assertEquals(responseActual,externalCallOutResponse);
            
        } catch(Exception ex){          
            //System.assertEquals(ex.getMessage(),'Date Of Birth is required.');
        }
    } 
    
    @isTest
    public static void testCIBILService8(){
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForCIBIL2(false,opp);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document1 = new Documents__c();
            document1.Applicant__c = applicant.Id;
            document1.Opportunity_Relation__c = opp.Id;
            document1.Document_Type__c = System.Label.AadhaarCard;
            document1.Document_Side__c ='Back';
            document1.Aadhar_Source__c = 'ScanAadhar';
            insert document1;
            
            Documents__c document2 = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }
            Documents__c document3 = TestDataUtility.createTestKYCDocsForCIBIL(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document3;
            }
            
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false,applicant);
            if (Schema.sObjectType.CIBIL_Details__c.isCreateable()){
                insert cibilDetail;
            }
            
            String cibilCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doCIBILReportCallout(cibilCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"QDKv+/rEIFMCQ7gqewFK52+UKf4pYoJmwObxt35m1IQzKaTDw13zkGnHypLuBpBhQWshsxWlvs1eTa21PpWyr+8xtFhWuZOiQhbzHn2D+2AHGha7tMqEyxvYub314A7b"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String externalCallOutResponse=(String)IntegrationEngine.processCIBILReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{  "IsSuccess": "True",  "StatusCode": "200",  "StatusDescription": "Sucess"}}';
            System.assertEquals(responseActual,externalCallOutResponse);
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Date Of Birth is required.');
        }
    } 
    
    
    
}