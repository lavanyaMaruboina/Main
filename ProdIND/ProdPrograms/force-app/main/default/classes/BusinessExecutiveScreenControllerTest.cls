/*------------------------------------------------------------
Author:        Haarika Chodisetti
Company:       Salesforce
Description:   This class is to test methods of BusinessExecutiveScreenController
History
Date            Author              Comments
-------------------------------------------------------------
25-10-2022      Haarika Chodisetti         Created
------------------------------------------------------------*/
@isTest
private class BusinessExecutiveScreenControllerTest {

    @isTest static void testGetApplicantId() {
        // Create test data
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opp',
            CloseDate = Date.today(),
            StageName = 'Closed Won',
            Product_Type__c = 'Personal Loan'
        );
        insert opportunity;
        Applicant__c applicant = new Applicant__c(
            Opportunity__c = opportunity.Id
        );
        insert applicant;
        
        // Call the method being tested
        Test.startTest();
        String result = BusinessExecutiveScreenController.getApplicantId(opportunity.Id);
        try{
            BusinessExecutiveScreenController.getApplicantId('invlaidId');
        }catch(Exception ex){}
        Test.stopTest();
        
        // Verify the result
        System.assertEquals(result, applicant.Id);
    }
    
    @isTest static void testFetchApplicationDetails() {
        // Create test data
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opp',
            CloseDate = Date.today(),
            StageName = 'Closed Won',
            Product_Type__c = 'Personal Loan'
        );
        insert opportunity;
        Applicant__c applicant = new Applicant__c(
            Opportunity__c = opportunity.Id
        );
        insert applicant;
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(
            Loan_Application__c = opportunity.Id
        );
        insert vehicleDetail;
        InsuranceDetails__c insurance = new InsuranceDetails__c(
            Loan_Application__c = opportunity.Id,
            Applicant__c = applicant.Id
        );
        insert insurance;
        
        // Call the method being tested
        Test.startTest();
        BusinessExecutiveScreenController.ApplicationDetails result = BusinessExecutiveScreenController.fetchApplicationDetails(opportunity.Id);
        try{
            BusinessExecutiveScreenController.fetchApplicationDetails('invlaidId');
        }catch(Exception ex){}
        Test.stopTest();
        
        // Verify the result
        System.assertEquals(result.applicant.Id, applicant.Id);
        System.assertEquals(result.vehicleDetail.Id, vehicleDetail.Id);
        System.assertEquals(result.insDetials.Id, insurance.Id);
    }
    
    @isTest static void testMoveToCreditProcessing() {
        // Create test data
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opp',
            CloseDate = Date.today(),
            StageName = 'Loan Initiation',
            Product_Type__c = 'Passenger Vehicles',
            Loan_Amount__c = '700000'
        );
        insert opportunity;
        Applicant__c applicant = new Applicant__c(
            Opportunity__c = opportunity.Id
        );
        insert applicant;
        InsuranceDetails__c insurance = new InsuranceDetails__c(
            Loan_Application__c = opportunity.Id,
            Applicant__c = applicant.Id,
            Name = 'MOTOR',
            Amount__c = 100.00,
            Funded_Non_funded__c = 'Funded'
        );
        insert insurance;
        Vehicle_Detail__c vd = TestDataUtility.createTestVehicleDetailForIbb(true, opportunity);
        Income_Details__c  income = new Income_Details__c (
            Applicant__c = applicant.Id
        ); 
        insert income;
        Final_Term__c ft = new Final_Term__c (
        	Loan_Application__c  = opportunity.Id
        );
        Documents__c doc1 = new Documents__c (
        	Opportunity_Relation__c  = opportunity.Id,
            Document_Type__c = 'PAN',
            Gender__c = 'MALE',
            KYC_DOB__c = Date.valueOf('2000-01-01'),
            Applicant__c = applicant.Id,
            Current_Residential_Address_Proof__c = true
        );
        insert doc1;
        Documents__c doc2 = new Documents__c (
        	Opportunity_Relation__c  = opportunity.Id,
            Document_Type__c = 'Aadhaar',
            Gender__c = 'MALE',
            KYC_DOB__c = Date.valueOf('2000-01-01'),
            Applicant__c = applicant.Id,
            Permanent_Residential_Address_Proof__c = true
        );
        insert doc2;        
        insert ft;
        // Call the method being tested
        Test.startTest();
        String result = BusinessExecutiveScreenController.moveToCreditProcessing(opportunity.Id);
        Test.stopTest();
        
        // Verify the result
        System.assert(result.length() >0);
        
        // Verify that the insurance records were updated
        insurance = [SELECT Funded_Premium__c FROM InsuranceDetails__c WHERE Id = :insurance.Id];
        System.assertEquals(insurance.Funded_Premium__c, 100.00);
    }

}