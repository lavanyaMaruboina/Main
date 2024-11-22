/**
* @Class: TaskCreationAPITest
* @Description: Test class for TaskCreationAPI
* @author: Siddhesh Jawale
* */
@isTest(seeAllData = False)
public class TaskCreationAPITest {
    
    @TestSetup
    private static void setupData(){
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ' ,'').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length() > 20 ){
            uniqueName = uniqueName.substring(0, 20);
        }
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,  MobilePhone='9999999999',
                          TimeZoneSidKey='Asia/Kolkata', UserName=uniqueName+'@testorg.com.test',EmployeeNumber = uniqueName, Maker_Id__c = '1001');
        insert u;
    }
    
    @isTest
    private static void testMissingFieldsPayload(){
        user u = [SELECT ID,EmployeeNumber FROM user  where Email ='NANDLAL1@testorg.com' limit 1][0];
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = u.EmployeeNumber;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Passenger Vehicles';
        insert beMaster;
        
        Account instofAcc = TestDataUtility.createTestAccount(false);
        instofAcc.BranchBLCode__c = 'HDT';
        insert instofAcc;
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        req.requestURI = '/services/apexrest/createWebformTask/'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        TaskCreationAPI.TaskWrapper tw = new TaskCreationAPI.TaskWrapper();
        tw.Subject = 'OUTGOING-ABANDONED-0';
        tw.Status = 'Completed';
        tw.CallStatus = 'ABANDONED';
        tw.call_type = 'OUTGOING';
        tw.Activitydate = '2022-05-11';
        tw.CallObject = '0';
        tw.customer_phone = '9091636263';
        tw.recording_file = '';
        tw.agent_id = 'agent1';
        tw.did_num = '12345';
        tw.extension_num = '8688664804';
        tw.process_name = 'LTFS_TW_PENAL';
        tw.queue_name = 'LTFS_TW_PENAL_WB1';
        tw.WhatId = instofAcc.Id;
        tw.isCTI_activity = 'true';
        tw.CallDisposition = 'CONGESTION';
        tw.Disposition = '';
        tw.Sub_Disposition= '';
        tw.CallDurationInSeconds = '0';
        
        String encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(tw),System.Label.privateKey,System.Label.ivkey); 
        
        //setting the response body
        String jdataRequest1 = '"JData":';                    
        String body1='{'+jdataRequest1 + '"'+encryptedResponse+'"'+'}';
        req.requestBody = Blob.valueOf(body1);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        TaskCreationAPI.createTask();
        
        TaskCreationAPI.ResponseWrapper reqData = (TaskCreationAPI.ResponseWrapper) JSON.deserialize(IntegrationUtilities.getPlainTextForLog(RestContext.response.responseBody.toString()), TaskCreationAPI.ResponseWrapper.class);
        System.assertEquals(reqData.success, FALSE);
        Test.stopTest(); 
    }
    
    @isTest
    private static void testCompletePayload(){
        user u = [SELECT ID,EmployeeNumber FROM user  where Email ='NANDLAL1@testorg.com' limit 1][0];
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = u.EmployeeNumber;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Passenger Vehicles';
        insert beMaster;
        
        Account instofAcc = TestDataUtility.createTestAccount(false);
        instofAcc.BranchBLCode__c = 'HDT';
        insert instofAcc;
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        req.requestURI = '/services/apexrest/createWebformTask/'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        TaskCreationAPI.TaskWrapper tw = new TaskCreationAPI.TaskWrapper();
        tw.Subject = 'OUTGOING-ABANDONED-0';
        tw.Status = 'Completed';
        tw.CallStatus = 'ABANDONED';
        tw.call_type = 'OUTGOING';
        tw.Activitydate = '2022-05-11';
        tw.CallObject = '0';
        tw.customer_phone = '9091636263';
        tw.recording_file = '';
        tw.agent_id = 'agent1';
        tw.did_num = '12345';
        tw.extension_num = '8688664804';
        tw.process_name = 'LTFS_TW_PENAL';
        tw.queue_name = 'LTFS_TW_PENAL_WB1';
        tw.WhatId = instofAcc.Id;
        tw.isCTI_activity = 'true';
        tw.CallDisposition = 'CONGESTION';
        tw.Disposition = 'CONGESTION';
        tw.Sub_Disposition= 'CONGESTION';
        tw.CallDurationInSeconds = '0';
        
        String encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(tw),System.Label.privateKey,System.Label.ivkey); 
        
        //setting the response body
        String jdataRequest1 = '"JData":';                    
        String body1='{'+jdataRequest1 + '"'+encryptedResponse+'"'+'}';
        req.requestBody = Blob.valueOf(body1);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        TaskCreationAPI.createTask();
        
        TaskCreationAPI.ResponseWrapper reqData = (TaskCreationAPI.ResponseWrapper) JSON.deserialize(IntegrationUtilities.getPlainTextForLog(RestContext.response.responseBody.toString()), TaskCreationAPI.ResponseWrapper.class);
        System.assertEquals(reqData.success, TRUE);
        Test.stopTest(); 
    }
    
    @isTest
    private static void testParsingError(){
        user u = [SELECT ID,EmployeeNumber FROM user  where Email ='NANDLAL1@testorg.com' limit 1][0];
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = u.EmployeeNumber;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Passenger Vehicles';
        insert beMaster;
        
        Account instofAcc = TestDataUtility.createTestAccount(false);
        instofAcc.BranchBLCode__c = 'HDT';
        insert instofAcc;
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        req.requestURI = '/services/apexrest/createWebformTask/'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        TaskCreationAPI.TaskWrapper tw = new TaskCreationAPI.TaskWrapper();
        String encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(tw),System.Label.privateKey,System.Label.ivkey); 
        
        //setting the response body
        String jdataRequest1 = '"JData":';                    
        String body1='{'+jdataRequest1 + '"'+encryptedResponse+'"'+'}';
        req.requestBody = Blob.valueOf(body1);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        TaskCreationAPI.createTask();
        
        TaskCreationAPI.ResponseWrapper reqData = (TaskCreationAPI.ResponseWrapper) JSON.deserialize(IntegrationUtilities.getPlainTextForLog(RestContext.response.responseBody.toString()), TaskCreationAPI.ResponseWrapper.class);
        System.assertEquals(reqData.success, FALSE);
        Test.stopTest(); 
    }
}