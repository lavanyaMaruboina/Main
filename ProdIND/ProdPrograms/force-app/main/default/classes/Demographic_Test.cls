@isTest
public class Demographic_Test {
     @isTest
    public static void docDemographicDetailsTest(){
        try{
                Opportunity opdw1 = new Opportunity();
                opdw1.StageName = 'Qualification';
                opdw1.CloseDate = Date.newInstance(2021, 1, 11);
                opdw1.Name = 'testone';
                insert opdw1;
                
                Applicant__c apdw1 = new Applicant__c();
                apdw1.Opportunity__c = opdw1.Id;
                apdw1.Contact_number__c = '9743514830';
                apdw1.Applicant_Type__c = 'Borrower';
                insert apdw1;
        
        Demographic.DemographicWrapper dw1 = new Demographic.DemographicWrapper();
        dw1.applicantId = apdw1.Id;
        dw1.preferredAddressForCommunication = 'testaddress';
        dw1.ofFamilyMembersResidingWithYou = 'testresi';
        dw1.residenceCountry = 'testcountry';
        dw1.whoWillPayTheLoan = 'testpay';
        dw1.maritalStatus = 'single';
        dw1.communicationLang = 'eng';
        dw1.customerQualification = 'ssc';
        dw1.emailId = 'test@gmail.com';
        dw1.spouseName = 'test';
        dw1.fatherName = 'king';
        dw1.motherName = 'Queen';
        dw1.contactNumber = '9999999999';
        dw1.relationshipWithBorrower = 'testneighbor';
        
        Test.startTest();
              Demographic.docDemographicDetails(Json.serialize(dw1));
        Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
                
    }
    
    @isTest
    public static void getDemographicDetailsTest(){
        
                Opportunity opgd1 = new Opportunity();
                opgd1.StageName = 'Qualification';
                opgd1.CloseDate = Date.newInstance(2021, 1, 11);
                opgd1.Name = 'testone';
                insert opgd1;
                
                Applicant__c apgd1 = new Applicant__c();
                apgd1.Opportunity__c = opgd1.Id;
                apgd1.Contact_number__c = '9743514830';
                apgd1.Applicant_Type__c = 'Borrower';
                insert apgd1;
        
               Test.startTest();
                     Demographic.getDemographicDetails(opgd1.Id,apgd1.Applicant_Type__c);
               Test.stopTest();
    }
    
     @isTest
    public static void getDemographicDetailsTest1(){
        
                Opportunity opgd1 = new Opportunity();
                opgd1.StageName = 'Qualification';
                opgd1.CloseDate = Date.newInstance(2021, 1, 11);
                opgd1.Name = 'testone';
                insert opgd1;
                
           /*     Applicant__c apgd1 = new Applicant__c();
                apgd1.Opportunity__c = opgd1.Id;
                apgd1.Contact_number__c = '9743514830';
                apgd1.Applicant_Type__c = 'Borrower';
                insert apgd1; */
        
               Test.startTest();
                     Demographic.getDemographicDetails(opgd1.Id,'test');
               Test.stopTest();
    }
    
    @isTest
    public static void getApplicantDetailsTest(){
        
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                insert apga1;
                 
                Test.startTest();
                       Demographic.getApplicantDetails(opga1.Id,apga1.Applicant_Type__c);
                Test.stopTest();
                 
    }
    
    
     @isTest
    static void testValidateBeneficiaryCount() {
        // Create test data
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            stagename='qualification',
            closedate=date.today()
           // Entity_Type__c = 'TestEntity' // Set the Entity Type
            // Add any required fields
        );
        insert testOpportunity;

        // Create related Applicant__c records
        Integer beneficiaryCount = 3; // Set the required beneficiary count
        List<Applicant__c> applicantList = new List<Applicant__c>();
        for (Integer i = 0; i < beneficiaryCount; i++) {
            applicantList.add(new Applicant__c(
                Name = 'Beneficiary ' + (i + 1),
                Applicant_Type__c = 'Beneficiary',
                Opportunity__c = testOpportunity.Id,
                In_Active_Applicant__c = false
                // Add any required fields
            ));
        }
        insert applicantList;

        // Create Required_Beneficiary_Counts__mdt records
        Required_Beneficiary_Counts__mdt benCountObj = new Required_Beneficiary_Counts__mdt(
            MasterLabel = 'TestEntity', // Entity Type to match the test Opportunity
            Beneficiary_Count__c = Integer.valueOf(beneficiaryCount) // Set the required beneficiary count
        );
        //insert benCountObj;

        // Call the method under test
        Test.startTest();
        Demographic.validateBeneficiaryCount(testOpportunity.Id);
        Test.stopTest();

        // Assert the results
      //  System.assertEquals(true, result.isValid, 'Validation status is incorrect');
     //   System.assertEquals(beneficiaryCount, result.beneficiaryCount, 'Beneficiary count is incorrect');
    }
    
     @isTest
    static void testGetApplicantDetail() {
        // Create test data
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            stagename='qualification',
            closedate=date.today()
            // Add any required fields
        );
        insert testOpportunity;

        Applicant__c testApplicant = new Applicant__c(
            Name = 'Test Applicant',
            Applicant_Type__c = 'Test Type',
            Opportunity__c = testOpportunity.Id,
            In_Active_Applicant__c = false
            // Add any required fields
        );
        insert testApplicant;

        // Call the method under test
        Test.startTest();
        List<Applicant__c> result = Demographic.getApplicantDetail(testOpportunity.Id);
         // Demographic.validateBeneficiaryCount(testOpportunity.Id);
        
        Test.stopTest();

        // Assert the results
       // System.assertEquals(1, result.size(), 'Incorrect number of applicants returned');
        // Assert other fields as needed
    }
 
    
}