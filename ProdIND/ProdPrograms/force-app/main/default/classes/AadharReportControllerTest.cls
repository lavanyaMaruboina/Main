@isTest
public class AadharReportControllerTest {   
     @isTest
    public static void testRes(){
        
                Opportunity opfu1 = new Opportunity();
                opfu1.StageName = 'Qualification';
                opfu1.CloseDate = Date.newInstance(2021, 1, 11);
                opfu1.Name = 'testone';
                insert opfu1;
                
                Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opfu1.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
                insert apfu1;
                
                 Documents__c dfu1 = new Documents__c();
                 dfu1.Applicant__c = apfu1.Id;
                 dfu1.Opportunity_Relation__c = opfu1.Id;
                 dfu1.Document_Type__c = 'Aadhaar';
                 dfu1.Document_Side__c ='Back';
                 dfu1.Aadhar_Source__c = 'ScanAadhar';
                 dfu1.Front_Upload_Attempts__c = 5;
                 insert dfu1;
        
                 PageReference testPage = Page.Ind_ApplicationForm; 
                 Test.setCurrentPage(testPage);
                 testPage.getParameters().put('Id', String.valueOf(dfu1.Id));
        
                 Test.startTest();
                      ApexPages.StandardController rs1 = new ApexPages.StandardController(dfu1);
                      AadharReportController arc = new AadharReportController(rs1);
                 Test.stopTest();
    }
    
  /*  @isTest
    public static void createAadharReportPdfTest(){
        Opportunity opfu1 = new Opportunity();
                opfu1.StageName = 'Qualification';
                opfu1.CloseDate = Date.newInstance(2021, 1, 11);
                opfu1.Name = 'testone';
                insert opfu1;
                
                Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opfu1.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
                insert apfu1;
                
                 Documents__c dfu1 = new Documents__c();
                 dfu1.Applicant__c = apfu1.Id;
                 dfu1.Opportunity_Relation__c = opfu1.Id;
                 dfu1.Document_Type__c = 'Aadhaar';
                 dfu1.Document_Side__c ='Back';
                 dfu1.Aadhar_Source__c = 'ScanAadhar';
                 dfu1.Front_Upload_Attempts__c = 5;
                 insert dfu1;
        
                 PageReference testPage = Page.Ind_ApplicationForm; 
                 Test.setCurrentPage(testPage);
                 testPage.getParameters().put('Id', String.valueOf(dfu1.Id));
                 
                 
                 
                 
                 Test.startTest();
                        AadharReportController.createAadharReportPdf(dfu1.Id);
                 Test.stopTest();
    } */
}