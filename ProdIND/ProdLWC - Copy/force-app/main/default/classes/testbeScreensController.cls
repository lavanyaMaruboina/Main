/*------------------------------------------------------------
Author:        Haarika Chodisetti
Company:       Salesforce
Description:   This class is to test methods of beScreensController
History
Date            Author              Comments
-------------------------------------------------------------
02-08-2022      Haarika Chodisetti         Created
------------------------------------------------------------*/
@isTest
private class testbeScreensController {
    
    /*
     * @Method:      testgetApplicantData
     * @Created by:  Haarika Chodisetti
     * @Description: Tests all methods of beScreensController
     * @Param:       
     * @Return:     
     History
     Date            Author              Comments
     -------------------------------------------------------------
     02-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    @isTest
    private static void testgetApplicantData(){
        Opportunity opp = TestDataUtility.createTestOpportunity(true);
    	Applicant__c app = TestDataUtility.createTestApplicantService(true, opp);
    	Vehicle_Detail__c vd = TestDataUtility.createTestVehicleDetailForIbb(true, opp);
    	Income_Details__c id = TestDataUtility.createIncomeDetailsRecord();
        id.Applicant__c =app.id;
        insert id;
    	Documents__c doc = TestDataUtility.createTestAadhaarDocs(true, app, opp);
    	InsuranceDetails__c insd = TestDataUtility.createInsuranceDetails(true, opp);
    	Existing_EMI__c exEMI = TestDataUtility.createTestEMIwithApp(true, app);
    	Final_Term__c finTerm = TestDataUtility.createfinalTerm(true, opp);
    	beScreensController.ApplicantDataWrapper result = beScreensController.getApplicantData(app.Id);
        beScreensController.ApplicantDataWrapper result1 = beScreensController.getRefreshedApplicantData(app.Id);
    }
	
    @isTest
    private static void testgetApplicantDataException(){
        try{
        	Opportunity opp = TestDataUtility.createTestOpportunity(true);
    		Applicant__c app = TestDataUtility.createTestApplicantService(true, opp);
        	beScreensController.ApplicantDataWrapper result = beScreensController.getApplicantData('12344567899');
        }catch (Exception e) {
            System.assertequals('Script-thrown exception', e.getMessage());
        }  
    }
}