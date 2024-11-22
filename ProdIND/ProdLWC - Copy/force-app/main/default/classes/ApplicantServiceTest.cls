@isTest(seeAllData = false)
public class ApplicantServiceTest{
/***********************************************************************************************************************
* @Method Name - IND_LWC_LoanDetailsCntlTest
* @Created by: Raj Gupta
* @description: IND_LWC_LoanDetailsCntlTest to test insert IND_LWC_LoanDetailsCntl class
***********************************************************************************************************************/
   @isTest
    public static void getApplicantsTest(){
        
        try{
        Opportunity opg1 = new Opportunity();
        opg1.StageName = 'Loan Initiation';
        opg1.CloseDate = Date.newInstance(2021, 1, 11);
        opg1.Name = 'testone';
        insert opg1;
        
        Applicant__c ag1 = new Applicant__c();
        ag1.Opportunity__c = opg1.Id;
        ag1.Applicant_Type__c = 'Borrower';
        ag1.Contact_number__c = '8341401752';
        insert ag1;
        
        Documents__c dcg1 = new Documents__c();
        dcg1.Applicant__c = ag1.Id;
        dcg1.Opportunity_Relation__c = opg1.Id;
        dcg1.Document_Type__c = 'Aadhaar';
        dcg1.Document_Side__c ='Back';
        dcg1.Current_Residential_Address_Proof__c = true;
        insert dcg1;
        
        Test.startTest();
            Ind_ApplicantService.getApplicantCurrentResidentialAddress(ag1.Id);
            Ind_ApplicantService.getApplicantCurrentResidentialAddress('test');
        Test.stopTest();
    
    }catch(Exception e){
        System.assertEquals('Script-thrown exception', e.getMessage());
    }
  
    }
    
    @isTest
    public static void savePrimaryOfficeAddressTest(){
        try{
        Opportunity opg2 = new Opportunity();
        opg2.StageName = 'Loan Initiation';
        opg2.CloseDate = Date.newInstance(2021, 1, 11);
        opg2.Name = 'testone';
        insert opg2;
        
        Applicant__c ag2 = new Applicant__c();
        ag2.Opportunity__c = opg2.Id;
        ag2.Applicant_Type__c = 'Borrower';
        ag2.Contact_number__c = '8341401752';
        insert ag2;
        
        Income_Details__c idt1 = new Income_Details__c();
        idt1.Applicant__c = ag2.Id;
        idt1.Name = 'testone';
        insert idt1;
        
        Ind_ApplicantService.ApplicantDetailsWrapper adw = new Ind_ApplicantService.ApplicantDetailsWrapper();
        adw.applicantId = opg2.Id;
        adw.name = 'testname';
        adw.street = 'teststreet';
        adw.addLine = 'testline';
        adw.pincode = '524315';
        adw.city = 'Bangalore';
        adw.district = 'testdist';
        adw.State = 'karnataka';
        adw.contactNumber = '9743514830';
        
        Test.startTest();
              Ind_ApplicantService.savePrimaryOfficeAddress(JSON.serialize(adw));
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
      }
    
    @isTest
    public static void savePrimaryOfficeAddressTest1(){
        try{
        Opportunity opg2 = new Opportunity();
        opg2.StageName = 'Loan Initiation';
        opg2.CloseDate = Date.newInstance(2021, 1, 11);
        opg2.Name = 'testone';
        insert opg2;
        
        Applicant__c ag2 = new Applicant__c();
        ag2.Opportunity__c = opg2.Id;
        ag2.Applicant_Type__c = 'Borrower';
        ag2.Contact_number__c = '8341401752';
        insert ag2;
        
        Ind_ApplicantService.ApplicantDetailsWrapper adw = new Ind_ApplicantService.ApplicantDetailsWrapper();
        adw.applicantId = ag2.Id;
        adw.name = 'testname';
        adw.street = 'teststreet';
        adw.addLine = 'testline';
        adw.pincode = '524315';
        adw.city = 'Bangalore';
        adw.district = 'testdist';
        adw.State = 'karnataka';
        adw.contactNumber = '9743514830';
            
        Income_Details__c idt1 = new Income_Details__c();
        idt1.Applicant__c = adw.applicantId;
        idt1.Name = 'testone';
        idt1.Primary_Income_Source__c = true;
        insert idt1;
        
        Test.startTest();
              Ind_ApplicantService.savePrimaryOfficeAddress(JSON.serialize(adw));
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
      }
    
    @isTest
    public static void updatePrimaryIncomeSourceTest(){
        try{
        Opportunity opg2 = new Opportunity();
        opg2.StageName = 'Loan Initiation';
        opg2.CloseDate = Date.newInstance(2021, 1, 11);
        opg2.Name = 'testone';
        insert opg2;
        
        Applicant__c ag2 = new Applicant__c();
        ag2.Opportunity__c = opg2.Id;
        ag2.Applicant_Type__c = 'Borrower';
        ag2.Contact_number__c = '8341401752';
        insert ag2;
        
        Income_Details__c idt1 = new Income_Details__c();
        idt1.Applicant__c = ag2.Id;
        idt1.Name = 'testone';
        idt1.Primary_Income_Source__c = true;
        insert idt1;
            
        Test.startTest();
              Ind_ApplicantService.updatePrimaryIncomeSource(ag2.Id);
              Ind_ApplicantService.updatePrimaryIncomeSource('test');
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updatePrimaryIncomeSourceTest1(){
        try{
        Opportunity opg2 = new Opportunity();
        opg2.StageName = 'Loan Initiation';
        opg2.CloseDate = Date.newInstance(2021, 1, 11);
        opg2.Name = 'testone';
        insert opg2;
        
        Applicant__c ag3 = new Applicant__c();
        ag3.Opportunity__c = opg2.Id;
        ag3.Applicant_Type__c = 'Borrower';
        ag3.Contact_number__c = '8341401752';
        insert ag3;
        
        
            
        Test.startTest();
              Ind_ApplicantService.updatePrimaryIncomeSource(ag3.Id);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getSavedDetailsTest(){
        try{
        Opportunity opg4 = new Opportunity();
        opg4.StageName = 'Loan Initiation';
        opg4.CloseDate = Date.newInstance(2021, 1, 11);
        opg4.Name = 'testone';
        insert opg4;
        
        Applicant__c ag4 = new Applicant__c();
        ag4.Opportunity__c = opg4.Id;
        ag4.Applicant_Type__c = 'Borrower';
        ag4.Contact_number__c = '8341401752';
        insert ag4;
        
        Income_Details__c idt1 = new Income_Details__c();
        idt1.Applicant__c = ag4.Id;
        idt1.Name = 'testone';
        idt1.Is_this_Current_Residence_Cum_office__c = true;
        idt1.Primary_Income_Source__c = true;
        insert idt1;
        
        Test.startTest();
              Ind_ApplicantService.getSavedDetails(ag4.Id,opg4.Id);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
 
}