/*------------------------------------------------------------
Author:        Haarika Chodisetti
Company:       Salesforce
Description:   This class is to test methods of conVoxAPIHandler
History
Date            Author              Comments
-------------------------------------------------------------
16-08-2022      Haarika Chodisetti         Created
------------------------------------------------------------*/
@isTest
public with sharing class conVoxAPIHandlerTest {
    /*
     * @Method:      conVoxAPIHandlerTest
     * @Created by:  Haarika Chodisetti
     * @Description: Tests all methods of conVoxAPIHandler with the help of CTIMockHttpClass
     * @Param:       
     * @Return:  void   
     History
     Date            Author              Comments
     -------------------------------------------------------------
     16-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    @isTest static void conVoxAPIHandlerTest1() {
        Opportunity opp = TestDataUtility.createTestOpportunity(true);
        Applicant__c app = TestDataUtility.createTestApplicantService(true, opp);
        app.Disposition__c = IntegrationConstants.DISPOSITION_NOT_INTERESTED;
        app.Sub_Disposition__c = IntegrationConstants.SUB_DISPOSITION_CAR_NOT_NEEDED;
        update app;
        Opportunity opp1 = TestDataUtility.createTestOpportunity1(true);
        Applicant__c app1 = TestDataUtility.createTestApplicantService(true, opp);
        app1.Disposition__c = IntegrationConstants.DISPOSITION_NOT_INTERESTED;
        app1.Sub_Disposition__c = IntegrationConstants.SUB_DISPOSITION_CAR_NOT_NEEDED;
        update app1;
        ConVox_Configuration__c configValues = ConVox_Configuration__c.getInstance();
        configValues.EndPoint__c = IntegrationConstants.CONVOX_END_POINT;
        upsert configValues; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, New CTIMockHttpClass());        
        conVoxAPIHandler.callApi(IntegrationConstants.CONVOX_DATAUPLOAD,app.Contact_number__c,app.Id);
        conVoxAPIHandler.callApi(IntegrationConstants.CONVOX_DELETELEAD,null, null);
        Test.stopTest();
    }
}