@isTest
public class UploadDataCustomResponseTest {
     @isTest
    public static void testOne(){
        
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
                 insert dtg1;
        
        Test.startTest();
            UploadDataCustomResponse ud1 = new UploadDataCustomResponse('test',dtg1.Id);
        Test.stopTest();
    }
}