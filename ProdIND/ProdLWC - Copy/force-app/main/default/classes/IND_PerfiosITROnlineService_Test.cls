/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   Test class for IND_PerfiosITROnlineRequest class 
Apex Class:    IND_PerfiosITROnlineRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Bhushan Charde       Created
------------------------------------------------------------*/
@isTest
public class IND_PerfiosITROnlineService_Test {
    
    // @Method:     TestServiceMetthod
    // @Created by: Bhushan Charde
    // @Description:Test setup method to create the test data for IND_PerfiosGSTOnlineRequest classs
    // @Param:      ''  
    // @Return:     '' 
    
     @isTest
    public static void getPerfiosITROnlineRequestTest(){
        try{
            
        Opportunity opgd1 = TestDataUtility.createTestLoanApplication(false);      
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        
        
        Vehicle_Detail__c vg3 = TestDataUtility.createTestVehicleDetailForIbb(false,opgd1);
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
      
        Product2 pd1 = TestDataUtility.createTestProduct2(false);
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.Channel ='IndusMobile';
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;
        requestWrapper.panNumber = '';
        requestWrapper.dateOfBirth = '01-01-1996';
        requestWrapper.contactNumber = '9765432345';
        requestWrapper.itrType = 'test';
          Test.startTest();
               IND_PerfiosITROnlineRequest result = IND_PerfiosITROnlineService.getPerfiosITROnlineRequest(requestWrapper);
          Test.stopTest();
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
    
    @isTest
    public static void getPerfiosITROnlineRequestTest1(){
    try{
        Opportunity opgd1 = TestDataUtility.createTestLoanApplication(false);      
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        
        
        Vehicle_Detail__c vg3 = TestDataUtility.createTestVehicleDetailForIbb(false,opgd1);
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
      
        Product2 pd1 = TestDataUtility.createTestProduct2(false);
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.Channel ='IndusMobile';
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;
        requestWrapper.panNumber = 'AZZPN9355R';
        requestWrapper.dateOfBirth = '';
        requestWrapper.contactNumber = '';
        requestWrapper.itrType = '';

          Test.startTest();
           try{
               IND_PerfiosITROnlineRequest result = IND_PerfiosITROnlineService.getPerfiosITROnlineRequest(requestWrapper);
               IND_PerfiosITROnlineRequest indPerfITRReq = new IND_PerfiosITROnlineRequest(requestWrapper);
               Map<String, String> mapOfGetHeaderRec = indPerfITRReq.getHttpRequestHeaders();
              }catch(Exception ex){
                  System.debug('Exception is -> '+ex.getMessage());
           }
        Test.stopTest();
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
   
    @isTest
    public static void testPerfiosITROnlineService(){
        try{
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c doc= TestDataUtility.createTestDocumentITR(false, applicant, opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert doc;
            }
            
            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"00671000001Dz1tAAC", "itrType":"ITROnline"}';            
            Continuation con = (Continuation)IntegrationEngine.doITROnlineCallout(str);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"cEYfHwBVCU8jDIBKeGynq9LwZLdDxpIkvbYiJZhBCTCaXTuKPIeBVRTsOSNbC41zNB0/a0Sa3qfDMptH4utz+AGvrgXyH+jmD4Vi4Hz17ulZMO1qSiS01uLdtWsMIRAner8b4VX9A7HHKiRpmauvFmB/2x29H6N8pu3brOVprd9E2FEJtIS/AD5og2uGy6fc2QsfLMKmkiu254/3GEqP1rNyNFp0gcItzs17Pk7npll9NSPYhEJMWkp2qw5t0qEsmMVI524NK2BAhFAYR6Fwba33+wSp4djjDPZHkCOca1Id0EgUaDNNLQDbIBO3axSqNB3ZW5aWLO7Y2i0Pcel0fodFRGE/Nxzjar4nd1gFjbw="}';
            //body = body.substring(10, body.length()-2); 
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            String itrResponse;
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                itrResponse = (String)IntegrationEngine.processITROnlineAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"body":null,"url":"https://apidemo.perfios.com/KYCServer/api/v2/tr/c5dbd097-a03d-4a84-a879-13c33b5c612b","generateLinkId":"c5dbd097-a03d-4a84-a879-13c33b5c612b","expires":"2022-01-16 18:08:25 Asia/Kolkata","clientTransactionId":"11012022180824156"}';
            System.assertEquals(responseExpected, itrResponse, 'Success');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
        
    // @Method:     TestServiceMetthod
    // @Created by: Bhushan Charde
    // @Description:Test setup method to create the test data for IND_PerfiosGSTOnlineRequest classs
    // @Param:      ''  
    // @Return:     '' 
    @isTest
    public static void testPerfiosITROnlineService2(){
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
            
             Documents__c doc= TestDataUtility.createTestDocumentITR(false, applicant, opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert doc;
            }

            
            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"00671000001Dz1tAAC", "itrType":""}';
            Continuation con = (Continuation)IntegrationEngine.doITROnlineCallout(str);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"cEYfHwBVCU8jDIBKeGynq9LwZLdDxpIkvbYiJZhBCTCaXTuKPIeBVRTsOSNbC41zNB0/a0Sa3qfDMptH4utz+AGvrgXyH+jmD4Vi4Hz17ulZMO1qSiS01uLdtWsMIRAner8b4VX9A7HHKiRpmauvFmB/2x29H6N8pu3brOVprd9E2FEJtIS/AD5og2uGy6fc2QsfLMKmkiu254/3GEqP1rNyNFp0gcItzs17Pk7npll9NSPYhEJMWkp2qw5t0qEsmMVI524NK2BAhFAYR6Fwba33+wSp4djjDPZHkCOca1Id0EgUaDNNLQDbIBO3axSqNB3ZW5aWLO7Y2i0Pcel0fodFRGE/Nxzjar4nd1gFjbw="}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String gstResponse = (String)IntegrationEngine.processITROnlineAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"url":"https://apidemo.perfios.com/KYCServer/api/v2/tr/c5dbd097-a03d-4a84-a879-13c33b5c612b","generateLinkId":"c5dbd097-a03d-4a84-a879-13c33b5c612b","expires":"2022-01-16 18:08:25 Asia/Kolkata","clientTransactionId":"11012022180824156"}';
            System.assertEquals(responseExpected, gstResponse, 'Success');
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),System.Label.PanTypeError, 'Exception');
        }
    }
    
    @isTest
    public static void testPerfiosITROnlineService3(){
        try{
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c doc= TestDataUtility.createTestDocumentITR(false, applicant, opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert doc;
            }
            
            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"00671000001Dz1tAAC", "itrType":"ITROnline"}';            
            Continuation con = (Continuation)IntegrationEngine.doITROnlineCallout(str);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"cEYfHwBVCU8jDIBKeGynq9LwZLdDxpIkvbYiJZhBCTCaXTuKPIeBVRTsOSNbC41zNB0/a0Sa3qfDMptH4utz+AGvrgXyH+jmD4Vi4Hz17ulZMO1qSiS01uLdtWsMIRAner8b4VX9A7HHKiRpmauvFmB/2x29H6N8pu3brOVprd9E2FEJtIS/AD5og2uGy6fc2QsfLMKmkiu254/3GEqP1rNyNFp0gcItzs17Pk7npll9NSPYhEJMWkp2qw5t0qEsmMVI524NK2BAhFAYR6Fwba33+wSp4djjDPZHkCOca1Id0EgUaDNNLQDbIBO3axSqNB3ZW5aWLO7Y2i0Pcel0fodFRGE/Nxzjar4nd1gFjbw="}';
            //body = body.substring(10, body.length()-2); 
            response.setBody(body);
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            String itrResponse;
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                itrResponse = (String)IntegrationEngine.processITROnlineAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"body":null,"url":"https://apidemo.perfios.com/KYCServer/api/v2/tr/c5dbd097-a03d-4a84-a879-13c33b5c612b","generateLinkId":"c5dbd097-a03d-4a84-a879-13c33b5c612b","expires":"2022-01-16 18:08:25 Asia/Kolkata","clientTransactionId":"11012022180824156"}';
            System.assertEquals(responseExpected, itrResponse, 'Success');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'No Response Found.', 'Exception');
        }
    } 
}