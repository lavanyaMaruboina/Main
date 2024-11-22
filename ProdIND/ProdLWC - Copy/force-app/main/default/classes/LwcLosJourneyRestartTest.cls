//This class is use to test journey Restart class : Raj Gupta
//Jira :- IND-374
@isTest
public class LwcLosJourneyRestartTest {
    @isTest
    public static void journeyRestartTest(){
                Opportunity opjr1 = new Opportunity();
                opjr1.StageName = 'Qualification';
                opjr1.CloseDate = Date.newInstance(2021, 1, 11);
                opjr1.Name = 'testone';
                insert opjr1;
                
                Applicant__c apjr1 = new Applicant__c();
                apjr1.Opportunity__c = opjr1.Id;
                apjr1.Contact_number__c = '9743514830';
                apjr1.Applicant_Type__c = 'Borrower';
                insert apjr1;
                
                 Documents__c dsjr1 = new Documents__c();
                 dsjr1.Applicant__c = apjr1.Id;
                 dsjr1.Opportunity_Relation__c = opjr1.Id;
                 dsjr1.Document_Type__c = 'Driving Licence';
                 dsjr1.Document_Side__c ='Back';
                 dsjr1.Aadhar_Source__c = 'ScanAadhar';
                 insert dsjr1;
        
                 Test.startTest();
                       LwcLosJourneyRestart.journeyRestart(dsjr1.Id);
                 Test.stopTest();
    }
    
     @isTest
    public static void journeyRestartTest1(){
                Opportunity opjr2 = new Opportunity();
                opjr2.StageName = 'Qualification';
                opjr2.CloseDate = Date.newInstance(2021, 1, 11);
                opjr2.Name = 'testone';
                insert opjr2;
                
                Applicant__c apjr2 = new Applicant__c();
                apjr2.Opportunity__c = opjr2.Id;
                apjr2.Contact_number__c = '9743514830';
                apjr2.Applicant_Type__c = 'Co-borrower';
                insert apjr2;
                
                 Documents__c dsjr1 = new Documents__c();
                 dsjr1.Applicant__c = apjr2.Id;
                 dsjr1.Opportunity_Relation__c = opjr2.Id;
                 dsjr1.Document_Type__c = 'Driving Licence';
                 dsjr1.Document_Side__c ='Back';
                 dsjr1.Aadhar_Source__c = 'ScanAadhar';
                 insert dsjr1;
        
                 Test.startTest();
                       LwcLosJourneyRestart.journeyRestart(dsjr1.Id);
                 Test.stopTest();
    }
}