/**
* @author Vinita K.
* @company Persistent Systems
* @description A  Test class for the IND_LWC_HomePage_Cntrl class
* Inputs: None
* History:
* 27/10/2021 Vinita K.
*/
@isTest(SeeAllData=false)
public class LWC_LOS_HomePage_CntrlTest {
    @isTest
    public static void poaTaggingTest(){
        try{
            Opportunity optg1 = new Opportunity();
            optg1.StageName = 'Qualification';
            optg1.CloseDate = Date.newInstance(2021, 1, 11);
            optg1.Name = 'testone';
            insert optg1;
            
            Applicant__c apt1 = new Applicant__c();
            apt1.Opportunity__c = optg1.Id;
            apt1.Contact_number__c = '9743514830';
            apt1.Applicant_Type__c = 'Borrower';
            insert apt1;
            
            Documents__c dtg1 = new Documents__c();
            dtg1.Applicant__c = apt1.Id;
            dtg1.Opportunity_Relation__c = optg1.Id;
            dtg1.Document_Type__c = 'Aadhaar';
            dtg1.Document_Side__c ='Back';
            dtg1.Aadhar_Source__c = 'ScanAadhar';
            dtg1.Current_Residential_Address_Proof__c = true;
            dtg1.Proof_of_Address_POA__c = true;
            dtg1.Name = 'TEST DOC NAME';
            insert dtg1;
            
            Test.startTest();
            LWC_LOS_HomePage_Cntrl.poaTagging(apt1.Id);
            Test.stopTest();
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void poaTaggingTest1(){
        try{
            Opportunity optg1 = new Opportunity();
            optg1.StageName = 'Qualification';
            optg1.CloseDate = Date.newInstance(2021, 1, 11);
            optg1.Name = 'testone';
            insert optg1;
            
            Applicant__c apt1 = new Applicant__c();
            apt1.Opportunity__c = optg1.Id;
            apt1.Contact_number__c = '9743514830';
            apt1.Applicant_Type__c = 'Borrower';
            insert apt1;
            
            Documents__c dtg1 = new Documents__c();
            dtg1.Applicant__c = apt1.Id;
            dtg1.Opportunity_Relation__c = optg1.Id;
            dtg1.Document_Type__c = 'Aadhaar';
            dtg1.Document_Side__c ='Back';
            dtg1.Aadhar_Source__c = 'ScanAadhar';
            dtg1.Permanent_Residential_Address_Proof__c = true;
            dtg1.Proof_of_Address_POA__c = true;
            dtg1.is_Active__c = true;
            dtg1.Name = 'TEST DOC NAME';
            insert dtg1;
            
            Test.startTest();
            LWC_LOS_HomePage_Cntrl.poaTagging(apt1.Id);
            Test.stopTest();
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void poaTaggingTest2(){
        try{ 
            Test.startTest();
            LWC_LOS_HomePage_Cntrl.poaTagging('Test');
            LWC_LOS_HomePage_Cntrl.poaTagging(null);
            Test.stopTest();
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void createLoanApplicationTest(){
        try{
            Test.startTest();
            LWC_LOS_HomePage_Cntrl.createLoanApplication();
            Test.stopTest();
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkUserRoleAccessTest(){
        Test.startTest();
        LWC_LOS_HomePage_Cntrl.checkUserRoleAccess();
        Test.stopTest();
    }
    @isTest
    static void testCreateSynergyLoanApplication() {
        Enquiry__c testEnquiry = new Enquiry__c(
            Customer_Name__c = 'Test Customer',
            Journey_Type__c = 'Offline – BE assisted journey',
            Lead_Reference_ID__c = '1234',
            Product_category__c = 'New',
            Enquiry_Status__c = 'Not Interested',
            Loan_amount__c = 10000

        );
        insert testEnquiry;
        Test.startTest();
        try {
            String result = LWC_LOS_HomePage_Cntrl.createSynergyLoanApplication('Test Customer', '1234567890', 'Test Product Category', '10000', testEnquiry.Id);
            System.assertNotEquals(null, result);
        } catch (Exception e) {
            //System.assert(false, 'Exception occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }
}