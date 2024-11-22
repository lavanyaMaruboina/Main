/*------------------------------------------------------------
Author:        Haarika Chodisetti
Company:       Salesforce
Description:   This class is to test methods of CTIApplicantViewController
History
Date            Author              Comments
-------------------------------------------------------------
03-08-2022      Haarika Chodisetti         Created
------------------------------------------------------------*/
@isTest
private class testCTIApplicantViewController {

    /*
     * @Method:      testgetApplicantData
     * @Created by:  Haarika Chodisetti
     * @Description: Tests all methods of CTIApplicantViewController
     * @Param:       
     * @Return:     
     History
     Date            Author              Comments
     -------------------------------------------------------------
     03-08-2022      Haarika Chodisetti         Created
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
    	Existing_EMI__c exEMI = TestDataUtility.createTestEMIwithApp(true, app);
        Test.startTest();
    	CTIApplicantViewController.ApplicantDataWrapper result = CTIApplicantViewController.getApplicantData(app.Id);
        CTIApplicantViewController.ApplicantDataWrapper result1 = CTIApplicantViewController.getRefreshedApplicantData(app.Id);
        try{
            CTIApplicantViewController.ApplicantDataWrapper result2 = CTIApplicantViewController.getApplicantData('123456778');
        }
        catch (Exception e) {
            system.debug('handled exception ');
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
        Test.stopTest();
    }
}